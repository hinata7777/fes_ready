class FestivalsController < ApplicationController
  before_action :set_festival, only: [ :show, :timetable ]
  before_action :ensure_timetable_published!, only: :timetable

  def index
    @artist = find_artist_by_identifier!(params[:artist_id]) if params[:artist_id].present?

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

    @timetable_query_params =
      params.permit(:from, :artist_id, :festival_id, :user_id).to_h

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

    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone

    @stages = @festival.stages.order(:sort_order, :id)

    @performances =
      @festival
        .stage_performances_for(@selected_day)
        .scheduled
        .includes(:stage, :artist)

    @performances_by_stage =
      @performances
        .reject { |performance| performance.stage_id.blank? }
        .group_by(&:stage_id)

    timeline_context = TimelineContextBuilder.build(
      festival: @festival,
      selected_day: @selected_day,
      timezone: @timezone
    )

    @timeline_start = timeline_context.timeline_start
    @timeline_end   = timeline_context.timeline_end
    @time_markers   = timeline_context.time_markers
    @timeline_layout = timeline_context.timeline_layout
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_days, :stages).find_by!(slug: params[:id])
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

  def find_artist_by_identifier!(identifier)
    Artist.find_by(uuid: identifier) || Artist.find(identifier)
  end
end
