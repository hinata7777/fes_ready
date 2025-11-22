module Festivals
  class FavoritesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_festival

    def create
      favorite = current_user.user_festival_favorites.find_or_create_by!(festival: @festival)

      respond_to do |format|
        format.html { redirect_back fallback_location: festival_path(@festival), notice: "お気に入りに追加しました" }
        format.json { render json: favorite_payload(favorited: true, favorite_id: favorite.id), status: :created }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_to do |format|
        format.html { redirect_back fallback_location: festival_path(@festival), alert: "お気に入り登録に失敗しました" }
        format.json { render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity }
      end
    end

    def destroy
      favorite = current_user.user_festival_favorites.find_by(festival: @festival)
      favorite&.destroy

      respond_to do |format|
        format.html { redirect_back fallback_location: festival_path(@festival), notice: "お気に入りを解除しました" }
        format.json { render json: favorite_payload(favorited: false), status: :ok }
      end
    end

    private

    def set_festival
      @festival = Festival.find_by_slug!(params[:festival_id])
    end

    def favorite_payload(favorited:, favorite_id: nil)
      {
        festival_id: @festival.id,
        favorited: favorited,
        favorite_id: favorite_id
      }.compact
    end
  end
end
