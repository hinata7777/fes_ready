module Mypage
  class FavoriteFestivalsController < ApplicationController
    before_action :authenticate_user!

    def index
      favorites_scope = current_user
                          .favorite_festivals
                          .includes(:festival_days, :stages)
                          .order(start_date: :asc, name: :asc)
      @pagy, @festivals = pagy(favorites_scope, limit: 20)
    end
  end
end
