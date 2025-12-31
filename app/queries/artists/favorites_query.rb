module Artists
  class FavoritesQuery
    def self.call(user:, scope: Artist.all)
      new(user: user, scope: scope).call
    end

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def call
      @scope
        .favorited_by(@user)
        .order(:name)
    end
  end
end
