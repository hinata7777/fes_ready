class FestivalsController < ApplicationController
  before_action :set_festival, only: :show
  # 一覧から渡された戻り先があれば採用する
  before_action :set_header_back_path, only: :show

  def index
    @artist = nil
    @status = Festival.normalized_status(params[:status])
    @status_labels = Festival.status_labels
    @festival_tags = FestivalTag.order(:name)
    @filter_params = filter_params
    @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

    festival_scope = Festival.for_status(@status)
    filtered_scope = apply_filters(festival_scope, @filter_params)

    @q     = filtered_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)
  end

  def show
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_tags).find_by_slug!(params[:id])
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
    back = params[:back_to].to_s
    return if back.blank?
    return unless back.start_with?("/")

    @header_back_path = back
  end
end
