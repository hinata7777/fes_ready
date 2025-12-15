module Mypage
  class FavoriteArtistsController < ApplicationController
    before_action :authenticate_user!

    def index
      favorites_scope = Artist.favorited_by(current_user)
      @pagy, @artists = pagy(favorites_scope, limit: 20)
    end
  end
end
