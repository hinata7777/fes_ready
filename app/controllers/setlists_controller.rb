class SetlistsController < ApplicationController
  include HeaderBackPath
  before_action :set_festival, only: :index
  before_action :set_header_back_path, only: :show

  def index
    raise ActiveRecord::RecordNotFound unless @festival.past?

    @festival_days = @festival.timetable_days
    @selected_day = @festival.select_day(params[:date], days: @festival_days)

    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone

    @performances = @festival
                      .stage_performances_on(@selected_day)
                      .scheduled
                      .includes(:artist, :stage, :setlist)
                      .order(:starts_at, :ends_at, :id)
    @stages = @festival.stages.order(:sort_order, :id)
    @performances_by_stage = @performances.group_by(&:stage)
  end

  def show
    @setlist = Setlist
                .includes(stage_performance: [ :artist, :stage, { festival_day: :festival } ],
                          setlist_songs: :song)
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
