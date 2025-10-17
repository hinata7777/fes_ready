class ArtistsController < ApplicationController
  def index
    base   = Artist.order(:name)
    @q     = base.ransack(params[:q])
    result = @q.result(distinct: true)

    @pagy, @artists = pagy(result, params: { q: params[:q] })
  end

  def show
    @artist = Artist.find(params[:id])
  end
end
