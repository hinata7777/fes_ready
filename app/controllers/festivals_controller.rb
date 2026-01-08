class FestivalsController < ApplicationController
  include HeaderBackPath
  before_action :set_festival, only: :show
  # 一覧から渡された戻り先があれば採用する
  before_action :set_header_back_path, only: :show

  def index
    @artist = nil
    @status = Festivals::ListQuery.normalized_status(params[:status])
    @festival_tags = FestivalTag.order(:name)
    @filter_params = Festivals::FilterQuery.permitted_params(params)
    @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

    festival_scope = Festivals::ListQuery.call(status: @status)
    filtered_scope = Festivals::FilterQuery.call(scope: festival_scope, filters: @filter_params)

    @q     = filtered_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)
    @back_to = request.fullpath
  end

  def show
    @show_setlists_link = @festival.past? && @festival.setlists_available?
    @festival_tags = @festival.sorted_tags
  end

  private

  def set_festival
    @festival = Festival.includes(:festival_tags).find_by_slug!(params[:id])
  end
end
