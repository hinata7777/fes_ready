module StageColumns
  class MyTimetablePickerColumnComponent < TimetableColumnBaseComponent
    def initialize(stage:, performances:, time_markers:, timeline_layout:, picked_ids: [])
      @stage = stage
      @performances = Array(performances)
      @time_markers = Array(time_markers)
      @timeline_layout = timeline_layout
      @picked_ids = Array(picked_ids)
    end

    def call
      render base_component
    end

    private

    attr_reader :stage, :performances, :time_markers, :timeline_layout, :picked_ids

    def base_component
      TimetableColumnBaseComponent.new(
        stage: stage,
        performances: performances,
        time_markers: time_markers,
        timeline_layout: timeline_layout,
        block_renderer_callback: method(:render_block)
      )
    end

    def render_block(performance, block)
      input_id = "stage-performance-#{performance.id}"
      checkbox = check_box_tag("stage_performance_ids[]",
                               performance.id,
                               picked_ids.include?(performance.id),
                               id: input_id,
                               class: "peer sr-only")

      check_icon = content_tag(:span,
                               image_tag("icons/check_mark.svg",
                                          alt: "",
                                          width: 18,
                                          height: 18,
                                          class: "h-4 w-4"),
                               class: "pointer-events-none absolute right-1 top-1 z-20 flex items-center justify-center rounded-full bg-white/95 p-[2px] opacity-0 shadow-sm transition transform scale-75 peer-checked:opacity-100 peer-checked:scale-100")

      selected_label = content_tag(:span,
                                   "選択中",
                                   class: "mt-auto hidden text-[10px] font-semibold uppercase tracking-wide peer-checked:inline opacity-100")

      label_body = default_block_content(block, performance.artist.name)

      label = content_tag(:label,
                          safe_join([ label_body, selected_label ]),
                          for: input_id,
                          class: "group flex h-full w-full cursor-pointer flex-col justify-start gap-px rounded-md border border-white/50 px-1.5 py-1 text-left text-[11px] font-semibold shadow-sm transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500 peer-checked:border-white peer-checked:shadow-lg peer-checked:ring-2 peer-checked:ring-white/80 interactive-lift sm:px-2.5 sm:py-2 sm:text-xs",
                          data: { controller: "tap-feedback" },
                          style: "background-color: #{stage_color}; color: #{stage_text_color};")

      content_tag(:div,
                  safe_join([ checkbox, check_icon, label ]),
                  class: "absolute inset-x-1.5 sm:inset-x-2",
                  style: "top: #{block.top_percent}%; height: #{block.height_percent}%;")
    end
  end
end
