module ArtistFavoritesHelper
  def artist_favorited?(artist)
    return false unless current_user
    @favorite_artist_ids ||= current_user.user_artist_favorites.pluck(:artist_id)
    @favorite_artist_ids.include?(artist.id)
  end
end
