module Weather
  # View に渡す「表示専用」のデータ構造。
  # ActiveRecord オブジェクトをそのまま View に渡すとロジックが散らばりやすいので、
  # ここで必要な情報だけに整形して渡す。
  Slot = Struct.new(:hour, :temperature_c, :weather_code, :icon_name, :tile_class, :temperature_label, keyword_init: true)
  Forecast = Struct.new(:date, :timezone, :venue_name, :hour_labels, :slots, keyword_init: true)

  class FestivalDayForecast
    TIMEZONE = "Asia/Tokyo"
    # 8〜22時を2時間刻みで表示する。
    # APIの hourly は「1時間ごと」なので、対象時刻だけ間引いて使う。
    DISPLAY_HOURS = [ 8, 10, 12, 14, 16, 18, 20, 22 ].freeze

    def initialize(festival_day:, client: OpenMeteo::Client.new, mapper: WeatherCodeMapper.new, cache: Rails.cache)
      @festival_day = festival_day
      @client = client
      @mapper = mapper
      @cache = cache
    end

    def call
      # 「日程未設定」など、要件を満たさない場合は nil を返して View 側で非表示にする。
      return if @festival_day.blank?

      festival = @festival_day.festival
      return if festival.blank?
      return if festival.latitude.blank? || festival.longitude.blank?

      date = @festival_day.date
      # 同じフェス・同じ日付の天気は、詳細画面を開き直しても頻繁に変わらないのでキャッシュする。
      json = @cache.fetch(cache_key(festival: festival, date: date), expires_in: 1.hour) do
        @client.hourly_forecast(
          latitude: festival.latitude,
          longitude: festival.longitude,
          date: date,
          timezone: TIMEZONE
        )
      end

      Forecast.new(
        # Open-Meteo の生JSONやActiveRecordをそのままViewに渡さず、表示に必要な形へまとめて渡すことで
        # View/Controllerが太りにくくなる。
        date: date,
        timezone: TIMEZONE,
        venue_name: festival.venue_name.presence || festival.name,
        hour_labels: DISPLAY_HOURS,
        slots: build_slots(json: json, date: date)
      )
    rescue StandardError => e
      Rails.logger.warn("[Weather] forecast fetch failed festival_day_id=#{@festival_day&.id} error=#{e.class}: #{e.message}")
      nil
    end

    private

    def cache_key(festival:, date:)
      # 予報の粒度（hourly）や用途が変わったときに衝突しないよう、version を含める。
      "weather:open_meteo:hourly:v1:festival=#{festival.id}:date=#{date.iso8601}:tz=#{TIMEZONE}"
    end

    def build_slots(json:, date:)
      hourly = json.fetch("hourly")
      times = hourly.fetch("time")
      temps = hourly.fetch("temperature_2m")
      codes = hourly.fetch("weather_code")

      # Open-Meteo は time/temperature/weather_code が「同じindex」で対応している。
      # time文字列 → index のmapを作り、欲しい時刻(0,3,6...)だけ取り出す。
      time_to_index = times.each_with_index.to_h

      DISPLAY_HOURS.filter_map do |hour|
        # Open-Meteo の time は "YYYY-MM-DDTHH:00" 形式（timezone 指定済み）。
        # 例: "2025-01-01T03:00"
        key = "#{date.iso8601}T#{format('%02d', hour)}:00"
        idx = time_to_index[key]
        next if idx.nil?

        code = codes[idx]
        temp_c = temps[idx].to_f
        Slot.new(
          hour: hour,
          temperature_c: temp_c,
          weather_code: code.to_i,
          # weather_code → アイコン/色 は mapper に寄せて View の分岐を減らす。
          icon_name: @mapper.icon_name_for(code),
          tile_class: @mapper.tile_class_for(code),
          temperature_label: "#{temp_c.round}℃"
        )
      end
    end
  end
end
