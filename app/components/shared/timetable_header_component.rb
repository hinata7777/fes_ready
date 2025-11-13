module Shared
  class TimetableHeaderComponent < ViewComponent::Base
    DEFAULT_CLASSES = "rounded-3xl border border-slate-200 bg-gradient-to-b from-sky-100 via-slate-100 to-white p-6 shadow-lg shadow-slate-200/60".freeze

    def initialize(title:, festival_name:, selected_day:, timezone:, header_classes: nil)
      @title = title
      @festival_name = festival_name
      @selected_day = selected_day
      @timezone = timezone
      @header_classes = header_classes.presence || DEFAULT_CLASSES
    end

    def call
      content_tag(:header, class: header_classes) do
        safe_join(compose_sections.compact)
      end
    end

    private

    attr_reader :title, :festival_name, :selected_day, :timezone, :header_classes

    def compose_sections
      [
        header_title,
        festival_heading,
        schedule_section,
        note_section,
        content_section
      ]
    end

    def header_title
      content_tag(:p, title, class: "text-xs font-semibold uppercase tracking-[0.3em] text-slate-500")
    end

    def festival_heading
      content_tag(:h1, festival_name, class: "mt-2 text-2xl font-extrabold text-slate-900")
    end

    def schedule_section
      content_tag(:div, class: "mt-4 flex flex-wrap items-center gap-4 text-sm text-slate-600") do
        content_tag(:div, class: "flex flex-wrap items-center gap-3 text-slate-900") do
          safe_join([ date_block, time_entries ])
        end
      end
    end

    def date_block
      content_tag(:div) do
        safe_join([
          content_tag(:span, "日付", class: "text-xs font-semibold uppercase tracking-wide text-slate-500"),
          content_tag(:div,
                      helpers.format_date_with_weekday(selected_day.date),
                      class: "text-base font-semibold text-slate-900")
        ])
      end
    end

    def time_entries
      content_tag(:div, class: "flex items-center gap-4 text-xs") do
        safe_join([
          time_entry("開場", selected_day.doors_at),
          time_entry("開演", selected_day.start_at),
          time_entry("終演", selected_day.end_at)
        ])
      end
    end

    def time_entry(label, time)
      content_tag(:div) do
        safe_join([
          content_tag(:span, label, class: "font-semibold uppercase tracking-wide text-slate-500"),
          content_tag(:div,
                      format_time(time),
                      class: "font-mono text-sm text-slate-800")
        ])
      end
    end

    def note_section
      return unless selected_day.note.present?

      content_tag(:p, selected_day.note, class: "mt-4 text-xs text-slate-600")
    end

    def content_section
      return unless content?

      content
    end

    def format_time(time)
      time ? time.in_time_zone(timezone).strftime("%H:%M") : "—"
    end
  end
end
