module Mypage
  class FavoriteFestivalsController < ApplicationController
    before_action :authenticate_user!

    def index
      favorites_scope = Festival.favorited_by(current_user)
      @pagy, @festivals = pagy(favorites_scope, items: 20)
    end
  end
end
