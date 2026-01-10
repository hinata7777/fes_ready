module Timetables
  class BoardComponent < ViewComponent::Base
    def initialize(stages:, time_markers:, timeline_layout:, timezone:, empty_message: "ステージ情報がありません",
                   stage_component:, performances_by_stage:, stage_component_options: {})
      @stages = Array(stages)
      @time_markers = Array(time_markers)
      @timeline_layout = timeline_layout
      @timezone = timezone
      @empty_message = empty_message
      @stage_component = stage_component
      @performances_by_stage = performances_by_stage || {}
      @stage_component_options = stage_component_options || {}
    end

    private

    attr_reader :stages, :time_markers, :timeline_layout, :timezone, :empty_message, :stage_component,
                :performances_by_stage, :stage_component_options

    def marker_timeline_style
      "height: #{timeline_layout.column_height_px}px;"
    end

    def marker_lines
      timeline_layout.marker_lines(time_markers)
    end

    def marker_labels
      timeline_layout.marker_labels(time_markers)
    end
  end
end
