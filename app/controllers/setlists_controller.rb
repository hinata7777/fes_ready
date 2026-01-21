class SetlistsController < ApplicationController
  include HeaderBackPath
  before_action :set_festival, only: :index
  before_action :set_header_back_path, only: :show

  def index
    raise ActiveRecord::RecordNotFound unless @festival.setlists_visible?

    @festival_days = @festival.timetable_days
    @selected_day = @festival.select_day(params[:date], days: @festival_days)

    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone

    @performances = @festival
                      .stage_performances_on(@selected_day)
                      .scheduled
                      .includes(:setlist)
                      .order(:starts_at, :ends_at, :id)
    @stages = @festival.stages.order(:sort_order, :id)

    # タブ情報とステージ別の表示用データをまとめて構築する
    context = SetlistsIndexViewContextBuilder.build(
      festival: @festival,
      festival_days: @festival_days,
      selected_day: @selected_day,
      performances: @performances,
      stages: @stages,
      back_to: request.fullpath,
      time_range_proc: ->(performance) { helpers.performance_time_range(performance, timezone: @timezone) }
    )
    @day_lookup = context[:day_lookup]
    @tab_items = context[:tab_items]
    @tab_url_builder = context[:tab_url_builder]
    @staged_performances = context[:staged_performances]
    @has_performances = context[:has_performances]
  end

  def show
    @setlist = Setlist
                .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ])
                .find_by!(uuid: params[:id])

    @stage_performance = @setlist.stage_performance
    @festival_day      = @stage_performance.festival_day
    @festival          = @festival_day.festival
    @setlist_songs     = @setlist.setlist_songs.includes(:song).order(:position)

    if params[:festival_id].present? && @festival.slug != params[:festival_id]
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def set_festival
    @festival = Festival.find_by_slug!(params[:festival_id])
  end
end
