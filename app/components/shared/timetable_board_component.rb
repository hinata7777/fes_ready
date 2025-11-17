module Shared
  class TimetableBoardComponent < ViewComponent::Base
    def initialize(stages:, time_markers:, timeline_layout:, timezone:, empty_message: "ステージ情報がありません", stage_renderer:)
      @stages = Array(stages)
      @time_markers = Array(time_markers)
      @timeline_layout = timeline_layout
      @timezone = timezone
      @empty_message = empty_message
      @stage_renderer = stage_renderer
    end

    def call
      content_tag(:section, class: section_classes) do
        content_tag(:div, class: "overflow-x-auto overflow-y-hidden") do
          content_tag(:div, class: "flex items-start gap-2 md:gap-3") do
            safe_join([ marker_column, stages_column ])
          end
        end
      end
    end

    private

    attr_reader :stages, :time_markers, :timeline_layout, :timezone, :empty_message, :stage_renderer

    def section_classes
      "rounded-3xl border border-slate-200 bg-gradient-to-b from-slate-100 via-white to-slate-100 p-3 shadow-lg shadow-slate-200/60 sm:p-4"
    end

    def marker_column
      content_tag(:div, class: "flex flex-shrink-0 flex-col items-center") do
        safe_join([ marker_column_header_spacer, marker_timeline ])
      end
    end

    def marker_column_header_spacer
      content_tag(:div, nil, class: "h-10 w-14 sm:h-12 sm:w-16")
    end

    def marker_timeline
      content_tag(:div,
                  class: "relative w-14 rounded-xl border border-slate-200 bg-white/80 text-[10px] font-semibold text-slate-600 sm:w-16 sm:text-[11px]",
                  style: "height: #{timeline_layout.column_height_px}px;") do
        safe_join([ marker_lines_content, marker_labels_content ])
      end
    end

    def marker_lines_content
      lines = timeline_layout.marker_lines(time_markers)
      elements = lines.map do |line|
        tag.div(class: "absolute inset-x-0 border-t border-slate-200/70", style: "top: #{line.top_percent}%;")
      end
      safe_join(elements)
    end

    def marker_labels_content
      labels = timeline_layout.marker_labels(time_markers)
      base_classes = "absolute inset-x-0 text-center pointer-events-none"

      elements = labels.map do |label|
        content_tag(:div,
                    content_tag(:span,
                                label.label_text,
                                class: "inline-block rounded bg-white/90 px-[3px] py-0.5 font-mono text-[9px] text-slate-700 shadow-sm sm:px-1 sm:text-[10px]"),
                    class: [ base_classes, label.css_translation_class ].join(" "),
                    style: "top: #{label.top_percent}%")
      end

      safe_join(elements)
    end

    def stages_column
      content_tag(:div, class: "flex flex-1 gap-2 md:gap-3") do
        if stages.any?
          stage_elements = stages.map { |stage| stage_renderer.call(stage) }
          safe_join(stage_elements)
        else
          empty_state
        end
      end
    end

    def empty_state
      content_tag(:div,
                  empty_message,
                  class: "flex h-full min-h-[320px] flex-1 items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-white/70 px-6 py-12 text-center text-sm text-slate-500")
    end
  end
end
