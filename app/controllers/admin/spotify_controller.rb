class Admin::SpotifyController < Admin::BaseController
  def search
    results = Spotify::SearchArtists.call(query: params[:q].to_s, limit: 10, market: "JP") # ← 固定
    render json: { artists: results, market: "JP" }
  rescue => e
    Rails.logger.error(e.full_message)
    render json: { artists: [], error: "Spotify検索でエラーが発生しました" }, status: :bad_gateway
  end

  def search_tracks
    results = Spotify::SearchTracks.call(query: params[:q].to_s, limit: 10, market: "JP") # ← 固定
    render json: { tracks: results, market: "JP" }
  rescue => e
    Rails.logger.error(e.full_message)
    render json: { tracks: [], error: "Spotify検索でエラーが発生しました" }, status: :bad_gateway
  end
end
