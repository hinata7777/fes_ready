module Mypage
  class FavoriteArtistsController < ApplicationController
    before_action :authenticate_user!

    def index
      favorites_scope = current_user.favorite_artists.order(:name)
      @pagy, @artists = pagy(favorites_scope, limit: 20)
    end
  end
end
