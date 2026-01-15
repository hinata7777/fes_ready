class TimelineContextBuilder
  DEFAULT_DAY_START_HOUR = 9
  MIN_TIMELINE_SPAN = 1.hour
  MAX_OVERNIGHT_EXTENSION = 8.hours

  Result = Struct.new(
    :timeline_start,
    :timeline_end,
    :time_markers,
    :timeline_layout,
    keyword_init: true
  )

  def self.build(festival:, selected_day:, timezone: nil)
    new(festival: festival, selected_day: selected_day, timezone: timezone).build
  end

  def initialize(festival:, selected_day:, timezone: nil)
    @festival = festival
    @selected_day = selected_day
    @timezone = timezone || ActiveSupport::TimeZone[festival.timezone] || Time.zone
  end

  def build
    timeline_start, timeline_end = calculate_range
    markers = build_markers(timeline_start, timeline_end)
    layout = TimelineLayoutPresenter.new(
      timeline_start: timeline_start,
      timeline_end: timeline_end,
      timezone: @timezone
    )

    Result.new(
      timeline_start: timeline_start,
      timeline_end: timeline_end,
      time_markers: markers,
      timeline_layout: layout
    )
  end

  private

  attr_reader :festival, :selected_day, :timezone

  def calculate_range
    day_date = selected_day.date
    day_start, max_day_end = day_bounds(day_date)
    doors_at, start_at, end_at = day_times(day_date)

    # 開場/開始/終了が未設定でも出演枠の時間からタイムラインを決められるようにする
    performance_start, performance_end = stage_time_range

    default_start = default_start_time(day_date, doors_at, start_at, performance_start)
    default_end = default_end_time(default_start, end_at, start_at, performance_start, performance_end)

    timeline_start = clamp_time(default_start, min: day_start, max: max_day_end)
    timeline_end   = clamp_time(default_end, min: timeline_start + MIN_TIMELINE_SPAN, max: max_day_end)

    [ timeline_start, timeline_end ]
  end

  def build_markers(timeline_start, timeline_end)
    # タイムライン内の1時間刻みマーカーを作る
    markers = [ timeline_start ]

    marker =
      if timeline_start.min.zero? && timeline_start.sec.zero?
        timeline_start + 1.hour
      else
        (timeline_start + 1.hour).change(min: 0, sec: 0)
      end

    while marker <= timeline_end
      markers << marker
      marker += 1.hour
    end

    markers << timeline_end unless markers.last == timeline_end
    markers
  end

  def day_bounds(day_date)
    # その日の開始（0時）と、翌日の深夜までの最大範囲を返す
    day_start = timezone.local(day_date.year, day_date.month, day_date.day).beginning_of_day
    max_day_end = day_start + 1.day + MAX_OVERNIGHT_EXTENSION
    [ day_start, max_day_end ]
  end

  def day_times(day_date)
    # 開場/開始/終了の時刻を同じ日付のローカル時刻として組み立てる
    doors_at = compose_time(selected_day.doors_at, day_date)
    start_at = compose_time(selected_day.start_at, day_date)
    end_at   = compose_time(selected_day.end_at, day_date)
    [ doors_at, start_at, end_at ]
  end

  def default_start_time(day_date, doors_at, start_at, performance_start)
    # 開場/開始/出演枠の最初がない場合はデフォルト開始時刻を使う
    doors_at || start_at || performance_start || timezone.local(day_date.year, day_date.month, day_date.day, DEFAULT_DAY_START_HOUR, 0, 0)
  end

  def default_end_time(default_start, end_at, start_at, performance_start, performance_end)
    # 終了が未設定なら、出演枠の最終 or 開始+8時間を採用する
    return adjusted_end_time(end_at, reference: default_start) if end_at

    fallback_end(default_start, start_at, performance_start, performance_end)
  end

  def fallback_end(default_start, start_at, performance_start, performance_end)
    performance_end || ((start_at || performance_start || default_start) + 8.hours)
  end

  def compose_time(time, day_date)
    # 指定日のローカル時刻として再構成する（不正値はnil扱い）
    return unless time

    local = time.in_time_zone(timezone)
    timezone.local(day_date.year, day_date.month, day_date.day, local.hour, local.min, local.sec)
  rescue
    nil
  end

  def stage_time_range
    # その日の出演枠から最小/最大の時刻を取り、タイムラインの基準にする
    scope = festival.stage_performances_on(selected_day).scheduled
    start_at = scope.minimum(:starts_at)
    end_at   = scope.maximum(:ends_at)
    return unless start_at && end_at
    [ start_at.in_time_zone(timezone), end_at.in_time_zone(timezone) ]
  end

  def clamp_time(value, min:, max:)
    # 開始/終了が日の範囲外に出ないように丸める（default_start/endがnilのときはminを使う）
    reference = value || min
    [ [ reference, min ].max, max ].min
  end

  def adjusted_end_time(time, reference:)
    # 終了時刻が開始より前なら翌日扱いにする（日跨ぎ開催フェスへの対応）
    time <= reference ? time + 1.day : time
  end
end
