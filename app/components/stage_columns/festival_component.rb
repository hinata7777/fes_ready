module StageColumns
  class FestivalComponent < BaseComponent
    def initialize(stage:, performances:, time_markers:, timeline_layout:, festival:, selected_day: nil)
      super(stage: stage, performances: performances, time_markers: time_markers, timeline_layout: timeline_layout)
      @festival = festival
      @selected_day = selected_day
    end

    private

    attr_reader :festival, :selected_day

    def render_block(performance, block)
      block_body = default_block_content(block, block.artist_name)
      block_style_rules = block_style(block, background_color: stage_color, text_color: stage_text_color)

      return content_tag(:div,
                         block_body,
                         class: default_block_classes,
                         style: block_style_rules) unless performance.artist.published?

      params = {
        from: "festival_timetable",
        festival_id: festival.slug,
        date: selected_day&.date&.to_s
      }.compact

      link_to(helpers.artist_path(performance.artist, params),
              class: default_block_classes,
              data: { controller: "tap-feedback" },
              style: block_style_rules) do
        block_body
      end
    end
  end
end
