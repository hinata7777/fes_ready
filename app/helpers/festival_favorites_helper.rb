module FestivalFavoritesHelper
  def festival_favorited?(festival)
    return false unless current_user
    festival.favorited_by?(current_user)
  end
end
