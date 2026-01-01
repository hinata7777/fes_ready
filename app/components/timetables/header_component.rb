module Timetables
  class HeaderComponent < ViewComponent::Base
    DEFAULT_CLASSES = "rounded-3xl border border-slate-200 bg-gradient-to-b from-sky-100 via-slate-100 to-white p-6 shadow-lg shadow-slate-200/60".freeze

    def initialize(title:, festival_name:, selected_day:, timezone:, header_classes: nil)
      @title = title
      @festival_name = festival_name
      @selected_day = selected_day
      @timezone = timezone
      @header_classes = header_classes.presence || DEFAULT_CLASSES
    end

    private

    attr_reader :title, :festival_name, :selected_day, :timezone, :header_classes

    def note?
      selected_day.note.present?
    end

    def format_time(time)
      time ? time.in_time_zone(timezone).strftime("%H:%M") : "—"
    end
  end
end
