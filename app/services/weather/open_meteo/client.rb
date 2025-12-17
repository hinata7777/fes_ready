require "net/http"
require "uri"
require "json"

module Weather
  module OpenMeteo
    class Client
      FORECAST_URL = "https://api.open-meteo.com/v1/forecast"

      def hourly_forecast(latitude:, longitude:, date:, timezone: "Asia/Tokyo")
        # Open-Meteo は start_date/end_date で日付範囲を指定できる。
        # 今回は「フェス当日」だけ欲しいので同一日付をセットする。
        uri = URI(FORECAST_URL)
        uri.query = URI.encode_www_form(
          latitude: latitude,
          longitude: longitude,
          # hourly は「1時間ごとの配列」で返るので、必要な項目だけ指定する。
          hourly: "temperature_2m,weather_code",
          start_date: date.iso8601,
          end_date: date.iso8601,
          # timezone を指定すると time がそのタイムゾーン基準で返る（今回は日本時間固定）。
          timezone: timezone
        )

        req = Net::HTTP::Get.new(uri)
        res = http(uri).request(req)
        raise "Open-Meteo forecast failed: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)

        JSON.parse(res.body)
      end

      private

      def http(uri) = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https")
    end
  end
end
