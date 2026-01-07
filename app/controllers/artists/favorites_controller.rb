module Artists
  class FavoritesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_artist

    def create
      favorite = current_user.user_artist_favorites.find_or_create_by!(artist: @artist)

      # JSONはStimulus用、HTMLはJSが無効な場合のフォールバック
      respond_to do |format|
        format.html { redirect_back fallback_location: artist_path(@artist), notice: "お気に入りに追加しました" }
        format.json { render json: favorite_payload(favorited: true, favorite_id: favorite.id), status: :created }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect_back fallback_location: artist_path(@artist), alert: "お気に入り登録に失敗しました" }
        format.json { render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity }
      end
    end

    def destroy
      favorite = current_user.user_artist_favorites.find_by(artist: @artist)
      favorite&.destroy

      # JSONはStimulus用、HTMLはJSが無効な場合のフォールバック
      respond_to do |format|
        format.html { redirect_back fallback_location: artist_path(@artist), notice: "お気に入りを解除しました" }
        format.json { render json: favorite_payload(favorited: false), status: :ok }
      end
    end

    private

    def set_artist
      @artist = Artist.find_by_identifier!(params[:artist_id])
    end

    def favorite_payload(favorited:, favorite_id: nil)
      {
        artist_id: @artist.id,
        favorited: favorited,
        favorite_id: favorite_id
      }.compact
    end
  end
end
