module StageColumns
  class BaseComponent < ViewComponent::Base
    def initialize(stage:, performances:, time_markers:, timeline_layout:)
      @stage = stage
      @performances = Array(performances)
      @time_markers = Array(time_markers)
      @timeline_layout = timeline_layout
    end

    def call
      content_tag(:div, class: wrapper_classes) do
        safe_join([ stage_header, timeline_body ])
      end
    end

    private

    attr_reader :stage, :performances, :time_markers

    def timeline_layout
      @timeline_layout || raise(ArgumentError, "timeline_layout is required")
    end

    def wrapper_classes
      "flex h-full min-w-[90px] flex-1 flex-col rounded-xl bg-white shadow-sm sm:min-w-[150px]"
    end

    def stage_header
      content_tag(:div,
                  stage.name,
                  class: "flex h-10 items-center justify-center rounded-t-xl px-2 text-center text-[11px] font-semibold uppercase tracking-wide sm:h-12 sm:px-3 sm:text-xs",
                  style: "background-color: #{stage_color}; color: #{stage_text_color};")
    end

    def timeline_body
      content_tag(:div,
                  class: "relative overflow-hidden rounded-b-xl border border-slate-200 bg-slate-50",
                  style: "height: #{timeline_layout.column_height_px}px;") do
        safe_join([ marker_lines_html, performance_blocks_container ])
      end
    end

    def marker_lines_html
      lines = timeline_layout.marker_lines(time_markers)
      elements = lines.map do |line|
        tag.div(class: "absolute inset-x-0 border-t border-slate-200/70",
                style: "top: #{line.top_percent}%;")
      end
      safe_join(elements)
    end

    def performance_blocks_container
      content_tag(:div, class: "relative h-full w-full") do
        safe_join(performance_blocks_html)
      end
    end

    def performance_blocks_html
      performances.filter_map do |performance|
        block = timeline_layout.performance_block(performance)
        next unless block
        render_block(performance, block)
      end
    end

    def default_block_classes
      "absolute inset-x-1.5 rounded-md px-2 py-1 text-[11px] font-semibold shadow-sm interactive-lift sm:inset-x-2 sm:px-3 sm:py-2 sm:text-xs"
    end

    def block_style(block, background_color:, text_color:, border: nil)
      style_rules = [
        "top: #{block.top_percent}%;",
        "height: #{block.height_percent}%;",
        "background-color: #{background_color};",
        "color: #{text_color};"
      ]
      style_rules << "border: #{border};" if border
      style_rules.join(" ")
    end

    def default_block_content(block, artist_name)
      time_label = block.end_label ? "#{block.start_label}-#{block.end_label}" : block.start_label

      time_block = content_tag(:div,
                               content_tag(:div, time_label, class: "whitespace-nowrap"),
                               class: "font-mono text-[9px] font-medium leading-none opacity-90 sm:text-[10px]")

      name_block = content_tag(:div,
                               artist_name,
                               class: "flex-1 overflow-hidden text-ellipsis text-[11px] font-bold leading-tight sm:text-xs")

      content_tag(:div, class: "flex h-full flex-col justify-start gap-px text-left") do
        safe_join([ time_block, name_block ])
      end
    end

    def stage_color
      @stage_color ||= stage.color_hex
    end

    def stage_text_color
      @stage_text_color ||= helpers.stage_text_color(stage_color)
    end

    def render_block(_performance, _block)
      raise NotImplementedError, "Subclasses must implement #render_block"
    end
  end
end
