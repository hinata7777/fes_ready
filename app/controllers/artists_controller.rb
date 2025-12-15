class ArtistsController < ApplicationController
  before_action :set_artist, only: :show

  def index
    @festival = nil
    @festival_days = []
    @selected_festival_day = nil

    artists_scope = Artist.published.order(:name)
    @q     = artists_scope.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: request.query_parameters)
  end

  def show; end

  private

  def set_artist
    @artist = Artist.find_published!(params[:id])
  end
end
