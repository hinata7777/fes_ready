module Mypage
  class FavoriteFestivalsController < ApplicationController
    before_action :authenticate_user!

    def index
      favorites_scope = Festivals::FavoritesQuery.call(user: current_user)
      @pagy, @festivals = pagy(favorites_scope, limit: 20)
    end
  end
end
