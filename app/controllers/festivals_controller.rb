class FestivalsController < ApplicationController
  before_action :set_festival, only: [ :show, :timetable ]
  before_action :ensure_timetable_published!, only: :timetable

  def index
    @artist = nil
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels

    base   = Festival.for_status(@status)
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
    relation = Festival.includes(:festival_days, :stages)
    @festival = Festival.find_by_slug!(params[:id], scope: relation)
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end
end
