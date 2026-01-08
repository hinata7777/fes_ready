class SetlistsIndexViewContextBuilder
  include Rails.application.routes.url_helpers

  def self.build(festival:, festival_days:, selected_day:, performances:, stages:, back_to:, time_range_proc:)
    new(
      festival: festival,
      festival_days: festival_days,
      selected_day: selected_day,
      performances: performances,
      stages: stages,
      back_to: back_to,
      time_range_proc: time_range_proc
    ).build
  end

  def initialize(festival:, festival_days:, selected_day:, performances:, stages:, back_to:, time_range_proc:)
    @festival = festival
    @festival_days = festival_days
    @selected_day = selected_day
    @performances = performances
    @stages = stages
    @back_to = back_to
    @time_range_proc = time_range_proc
  end

  def build
    day_lookup = @festival_days.index_by(&:id)
    tab_items = day_lookup.transform_values { |day| day.date.strftime("%-m/%-d") }
    # 日付タブから該当日のセットリストURLを組み立てるためのlambda
    tab_url_builder = ->(festival_day_id) do
      day = day_lookup[festival_day_id]
      festival_setlists_path(@festival, date: day.date.to_s)
    end

    performances_by_stage = @performances.group_by(&:stage)
    # ステージごとの表示用エントリーを整形して渡す
    staged_performances = @stages.filter_map do |stage|
      stage_performances = performances_by_stage[stage]
      next if stage_performances.blank?

      entries = stage_performances.map do |performance|
        label = performance.artist&.name || "(未定)"
        subtext = @time_range_proc.call(performance)
        disabled = performance.setlist.blank?
        url = disabled ? nil : festival_setlist_path(@festival, performance.setlist, back_to: @back_to)

        { label: label, subtext: subtext, disabled: disabled, url: url }
      end

      { stage: stage, entries: entries }
    end

    {
      day_lookup: day_lookup,
      tab_items: tab_items,
      tab_url_builder: tab_url_builder,
      staged_performances: staged_performances,
      has_performances: staged_performances.any?
    }
  end
end
