class Festivals::ArtistsController < ApplicationController
  include HeaderBackPath
  before_action :set_festival
  before_action :set_festival_days
  before_action :set_header_back_path
  # 一覧→詳細で戻るときに元の一覧URLを渡すためのパラメータ
  before_action :set_back_to_param

  def index
    artists_scope = @festival.artists_for_day(@selected_festival_day)

    @q     = artists_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: request.query_parameters)
    prepare_index_view_context

    render "artists/index"
  end

  private

  def set_festival
    @festival = Festival.find_by_slug!(params[:festival_id])
  end

  def set_festival_days
    @festival_days = @festival.festival_days.order(:date)
    @selected_festival_day = @festival_days.find_by(id: params[:festival_day_id]) || @festival_days.first
  end

  def default_back_path
    # back_to が無い場合はフェス詳細に戻す
    festival_path(@festival) if @festival
  end

  def set_back_to_param
    # 現在の一覧URLを保存し、詳細遷移時の戻り先として渡す
    @back_to = request.fullpath
  end

  def prepare_index_view_context
    # TODO: 画面ロジックが増えたらViewContext/Presenterに移す
    @show_day_tabs = @festival.present? && @festival_days.any?
    @preserved_query = request.query_parameters.except(:page, :festival_day_id)
    @tab_items = @festival_days.map { |festival_day| [ festival_day.id, festival_day.date.strftime("%-m/%-d") ] }.to_h
    @tab_url_builder = ->(festival_day_id) { festival_artists_path(@festival, @preserved_query.merge(festival_day_id: festival_day_id)) }
    @search_url = festival_artists_path(@festival, festival_day_id: @selected_festival_day&.id)
    @search_hidden_fields = @selected_festival_day ? { festival_day_id: @selected_festival_day.id } : {}
    @selected_day_label = @selected_festival_day&.date&.strftime("%-m/%-d")
    @show_selected_day_label = @selected_festival_day.present?
  end
end
