class TimelineContextBuilder
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
    day_start = timezone.local(day_date.year, day_date.month, day_date.day).beginning_of_day
    day_end   = day_start.end_of_day

    doors_at = compose_time(selected_day.doors_at, day_date)
    start_at = compose_time(selected_day.start_at, day_date)
    end_at   = compose_time(selected_day.end_at, day_date)

    default_start = doors_at || start_at || timezone.local(day_date.year, day_date.month, day_date.day, 9, 0, 0)
    default_end   = end_at || (start_at || default_start) + 8.hours

    timeline_start = [ [ default_start, day_start ].max, day_end ].min
    timeline_end   = [ [ default_end, day_start ].max, day_end ].min

    if timeline_end <= timeline_start
      timeline_end = [ timeline_start + 1.hour, day_end ].min
    end

    [ timeline_start, timeline_end ]
  end

  def build_markers(timeline_start, timeline_end)
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

  def compose_time(time, day_date)
    return unless time

    local = time.in_time_zone(timezone)
    timezone.local(day_date.year, day_date.month, day_date.day, local.hour, local.min, local.sec)
  rescue
    nil
  end
end
