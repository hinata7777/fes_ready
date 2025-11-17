class TimetablesController < ApplicationController
  before_action :set_festival, only: :show
  before_action :ensure_timetable_published!, only: :show
  before_action :load_festival_days, only: :show

  def index
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels

    published_festivals = Festival.with_published_timetable
    scoped = published_festivals.merge(Festival.for_status(@status))

    @q = scoped.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, items: 20, params: pagy_params)
  end

  def show
    extract_timetable_params
    resolve_selected_day
    build_timeline_context

    @stages = @festival.stages.order(:sort_order, :id)
    @performances_by_stage = performances_by_stage
  end

  private

  def set_festival
    festival_relation = Festival.includes(:festival_days, :stages)
    @festival = Festival.find_by_slug!(params[:id], scope: festival_relation)
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end

  def load_festival_days
    @festival_days = @festival.timetable_days
    raise ActiveRecord::RecordNotFound if @festival_days.blank?
  end

  def extract_timetable_params
    @timetable_query_params = timetable_query_params
  end

  def resolve_selected_day
    @selected_day =
      if params[:date].present?
        begin
          parsed = Date.parse(params[:date])
        rescue ArgumentError
          raise ActiveRecord::RecordNotFound
        end
        @festival.festival_days.find_by!(date: parsed)
      else
        @festival_days.first
      end
  end

  def build_timeline_context
    @timezone = ActiveSupport::TimeZone[@festival.timezone] || Time.zone

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

  def performances_by_stage
    @performances_by_stage ||=
      @festival
        .stage_performances_on(@selected_day)
        .scheduled
        .where.not(stage_id: nil)
        .includes(:stage, :artist)
        .group_by(&:stage_id)
  end

  def timetable_query_params
    params.permit(:from, :artist_id, :festival_id, :user_id).to_h
  end
end
