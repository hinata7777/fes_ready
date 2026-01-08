class ArtistsController < ApplicationController
  include HeaderBackPath
  before_action :set_artist, only: :show
  # 一覧から渡された戻り先があれば採用する
  before_action :set_header_back_path, only: :show

  def index
    @festival = nil
    @festival_days = []
    @selected_festival_day = nil

    artists_scope = Artist.published.order(:name)
    @q     = artists_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: request.query_parameters)
    @back_to = request.fullpath
    prepare_index_view_context
  end

  def show; end

  private

  def set_artist
    @artist = Artist.find_published!(params[:id])
  end

  def prepare_index_view_context
    # TODO: 画面ロジックが増えたらViewContext/Presenterに移す
    @show_day_tabs = @festival.present? && @festival_days.any?
    @preserved_query = request.query_parameters.except(:page, :festival_day_id)
    @tab_items = @festival_days.map { |festival_day| [ festival_day.id, festival_day.date.strftime("%-m/%-d") ] }.to_h
    @tab_url_builder = ->(festival_day_id) { festival_artists_path(@festival, @preserved_query.merge(festival_day_id: festival_day_id)) }
    @search_url = artists_path
    @search_hidden_fields = {}
    @selected_day_label = nil
    @show_selected_day_label = false
  end
end
