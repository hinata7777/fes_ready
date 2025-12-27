module Festivals
  class FavoritesQuery
    def self.call(user:, scope: Festival.all)
      new(user: user, scope: scope).call
    end

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def call
      # 一覧表示で必要な関連を先読みしてN+1を避ける。
      @scope
        .favorited_by(@user)
        .includes(:festival_days, :stages)
        .order(start_date: :asc, name: :asc)
    end
  end
end
