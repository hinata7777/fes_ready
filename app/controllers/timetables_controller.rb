class TimetablesController < ApplicationController
  before_action :set_festival, only: :show
  before_action :ensure_timetable_published!, only: :show
  before_action :load_festival_days, only: :show
  before_action :set_header_back_path, only: :show

  def index
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels
    @festival_tags = FestivalTag.order(:name)
    @filter_params = filter_params
    @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

    published_festivals = Festival.with_published_timetable
    scoped = published_festivals.merge(Festival.for_status(@status))

    filtered_scope = apply_filters(scoped, @filter_params)

    @q = filtered_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)
  end

  def show
    extract_timetable_params
    resolve_selected_day
    build_timeline_context

    @stages = @festival.stages.sort_by { |stage| [ stage.sort_order || 0, stage.id ] }
    @performances_by_stage = performances_by_stage
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_days, :stages).find_by_slug!(params[:id])
  end

  def ensure_timetable_published!
    raise ActiveRecord::RecordNotFound unless @festival.timetable_published?
  end

  def load_festival_days
    @festival_days = @festival.festival_days.sort_by(&:date)
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
        .group_by(&:stage)
  end

  def timetable_query_params
    params.permit(:from, :artist_id, :festival_id, :user_id, :back_to).to_h
  end

  def filter_params
    params.permit(:start_date_from, :end_date_to, :area, tag_ids: [])
  end

  def apply_filters(scope, filters)
    filtered = scope

    from_date = parse_date(filters[:start_date_from])
    to_date   = parse_date(filters[:end_date_to])

    filtered = filtered.where("start_date >= ?", from_date) if from_date
    filtered = filtered.where("end_date <= ?", to_date) if to_date

    if filters[:area].present? && Regions::AREA_PREFECTURES.key?(filters[:area])
      prefectures = Regions::AREA_PREFECTURES[filters[:area]]
      filtered = filtered.where(prefecture: prefectures)
    end

    tag_ids = Array(filters[:tag_ids]).reject(&:blank?).map(&:to_i)
    if tag_ids.any?
      filtered = filtered
                   .joins(:festival_festival_tags)
                   .where(festival_festival_tags: { festival_tag_id: tag_ids })
                   .group("festivals.id")
                   .having("COUNT(DISTINCT festival_festival_tags.festival_tag_id) = ?", tag_ids.size)
    end

    filtered
  end

  def parse_date(value)
    return if value.blank?
    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def set_header_back_path
    return unless @festival
    back = params[:back_to].to_s
    if back.start_with?("/")
      @header_back_path = back
      return
    end
    return unless back == "festival"

    @header_back_path = festival_path(@festival)
  end
end
