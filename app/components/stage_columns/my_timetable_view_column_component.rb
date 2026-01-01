module StageColumns
  class MyTimetableViewColumnComponent < TimetableColumnBaseComponent
    def initialize(stage:, performances:, time_markers:, timeline_layout:, festival:, selected_day:, selected_ids:, owner_identifier: nil, back_to: nil)
      @stage = stage
      @performances = Array(performances)
      @time_markers = Array(time_markers)
      @timeline_layout = timeline_layout
      @festival = festival
      @selected_day = selected_day
      @selected_ids = Array(selected_ids)
      @owner_identifier = owner_identifier
      @back_to = back_to
    end

    def call
      render base_component
    end

    private

    attr_reader :stage, :performances, :time_markers, :timeline_layout,
                :festival, :selected_day, :selected_ids, :owner_identifier, :back_to

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
      selected = selected_ids.include?(performance.id)
      background_color = selected ? stage_color : unselected_hex
      text_color = selected ? stage_text_color : unselected_text_color
      border_color = selected ? "rgba(255,255,255,0.7)" : "rgba(148,163,184,0.7)"
      classes = [ default_block_classes, (selected ? nil : "opacity-80") ].compact.join(" ")
      block_body = default_block_content(block, block.artist_name, canceled: canceled?(performance))
      block_style_rules = block_style(block,
                                      background_color: background_color,
                                      text_color: text_color,
                                      border: "1px solid #{border_color}")

      return content_tag(:div,
                         block_body,
                         class: classes,
                         style: block_style_rules) unless performance.artist.published?

      artist_url = back_to.present? ? helpers.artist_path(performance.artist, back_to: back_to) : helpers.artist_path(performance.artist)
      link_to(artist_url,
              class: classes,
              data: { controller: "tap-feedback" },
              style: block_style_rules
              ) do
        block_body
      end
    end

    def unselected_hex
      "#e2e8f0"
    end

    def unselected_text_color
      "#1f2937"
    end
  end
end
