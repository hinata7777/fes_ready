module Timetables
  class ViewContextBuilder
    Result = Struct.new(
      :timezone,
      :timeline_start,
      :timeline_end,
      :time_markers,
      :timeline_layout,
      keyword_init: true
    )

    def self.build(festival:, selected_day:)
      new(festival: festival, selected_day: selected_day).build
    end

    def initialize(festival:, selected_day:)
      @festival = festival
      @selected_day = selected_day
    end

    def build
      timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone
      timeline_context = TimelineContextBuilder.build(
        festival: @festival,
        selected_day: @selected_day,
        timezone: timezone
      )

      Result.new(
        timezone: timezone,
        timeline_start: timeline_context.timeline_start,
        timeline_end: timeline_context.timeline_end,
        time_markers: timeline_context.time_markers,
        timeline_layout: timeline_context.timeline_layout
      )
    end
  end
end
