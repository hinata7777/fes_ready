module FavoritesHelper
  def favorite_button_for(favorited:, toggle_url:)
    return unless user_signed_in?

    render "shared/favorite_button",
           favorited: !!favorited,
           toggle_url: toggle_url,
           icons: favorite_icons
  end

  def favorite_icons
    {
      empty:  asset_path("icons/heart.svg"),
      filled: asset_path("icons/heart_filled.svg")
    }
  end
end
