class FestivalsController < ApplicationController
  before_action :set_festival, only: [:show, :timetable]
  before_action :ensure_timetable_published!, only: :timetable
  
  def index
    @artist = Artist.find(params[:artist_id]) if params[:artist_id].present?

    @status = params[:status]
    @status = "upcoming" unless %w[upcoming past].include?(@status)
    @status_labels = { "upcoming" => "開催前", "past" => "開催済み" }

    base   = filtered_festivals
    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end

  def show
  end

  def timetable
    @festival_days = @festival.timetable_days
    raise ActiveRecord::RecordNotFound if @festival_days.blank?

    @selected_day =
      if params[:date].present?
        begin
          date = Date.parse(params[:date])
        rescue ArgumentError
          raise ActiveRecord::RecordNotFound
        end
        @festival.festival_days.find_by!(date: date)
      else
        @festival_days.first
      end

    @stages = @festival.stages.order(:name)

    @performances = @festival.stage_performances_for(@selected_day)
    @performances_by_stage = @performances.group_by(&:stage_id)
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_days, :stages).find(params[:id])
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end
  
  def filtered_festivals
    relation =
      if @artist
        @artist.festivals.merge(Festival.ordered)
      else
        Festival.ordered
      end

    today = Date.current
    scoped =
      case @status
      when "past" then relation.merge(Festival.past(today))
      else           relation.merge(Festival.upcoming(today))
      end

    scoped.distinct
  end
end