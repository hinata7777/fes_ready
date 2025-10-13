class ArtistsController < ApplicationController
  def index
    @pagy, @artists = pagy Artist.order(:name)
  end

  def show
    @artist = Artist.find(params[:id])
  end
end
