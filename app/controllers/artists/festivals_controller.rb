class Artists::FestivalsController < ApplicationController
  include HeaderBackPath
  before_action :set_artist
  before_action :set_header_back_path
  # 一覧→詳細で戻るときに元の一覧URLを渡すためのパラメータ
  before_action :set_back_to_param

  def index
    @status = Festivals::ListQuery.normalized_status(params[:status])
    @festival_tags = FestivalTag.order(:name)
    @filter_params = Festivals::FilterQuery.permitted_params(params)
    @selected_tag_ids = Array(@filter_params[:tag_ids]).reject(&:blank?).map(&:to_i)

    festival_scope = Festivals::ListQuery.call(status: @status, scope: @artist.festivals)
    filtered_scope = Festivals::FilterQuery.call(scope: festival_scope, filters: @filter_params)

    @q   = filtered_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    pagy_params = request.query_parameters.merge(status: @status)
    @pagy, @festivals = pagy(result, limit: 20, params: pagy_params)

    render "festivals/index"
  end

  private

  def set_artist
    @artist = Artist.find_by_identifier!(params[:artist_id])
  end

  def set_back_to_param
    # 現在の一覧URLを保存し、詳細遷移時の戻り先として渡す
    @back_to = request.fullpath
  end

  def default_back_path
    # back_to が無い場合はアーティスト詳細に戻す
    artist_path(@artist) if @artist
  end
end
