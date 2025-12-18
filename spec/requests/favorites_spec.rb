require "rails_helper"

RSpec.describe "お気に入りのリクエスト", type: :request do
  describe "POST /festivals/:festival_id/favorite" do
    let(:user) { create(:user) }
    let(:festival) { create(:festival) }

    context "ログイン済みのとき" do
      before { sign_in user, scope: :user }

      it "フェスのお気に入りを登録し、JSONで201を返す" do
        expect {
          post festival_favorite_path(festival), as: :json
        }.to change { user.user_festival_favorites.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include(
          "festival_id" => festival.id,
          "favorited" => true
        )
      end
    end

    context "未ログインのとき" do
      it "401 を返し、登録されない" do
        expect {
          post festival_favorite_path(festival), as: :json
        }.not_to change(UserFestivalFavorite, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to include("ログイン")
      end
    end
  end

  describe "DELETE /festivals/:festival_id/favorite" do
    let(:user) { create(:user) }
    let(:festival) { create(:festival) }
    let!(:favorite) { create(:user_festival_favorite, user: user, festival: festival) }

    context "ログイン済みのとき" do
      before { sign_in user, scope: :user }

      it "フェスのお気に入りを削除し、JSONで200を返す" do
        expect {
          delete festival_favorite_path(festival), as: :json
        }.to change { user.user_festival_favorites.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          "festival_id" => festival.id,
          "favorited" => false
        )
      end
    end
  end

  describe "POST /artists/:artist_id/favorite" do
    let(:user) { create(:user) }
    let(:artist) { create(:artist) }

    context "ログイン済みのとき" do
      before { sign_in user, scope: :user }

      it "アーティストのお気に入りを登録し、JSONで201を返す" do
        expect {
          post artist_favorite_path(artist), as: :json
        }.to change { user.user_artist_favorites.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include(
          "artist_id" => artist.id,
          "favorited" => true
        )
      end
    end

    context "未ログインのとき" do
      it "401 を返し、登録されない" do
        expect {
          post artist_favorite_path(artist), as: :json
        }.not_to change(UserArtistFavorite, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to include("ログイン")
      end
    end
  end

  describe "DELETE /artists/:artist_id/favorite" do
    let(:user) { create(:user) }
    let(:artist) { create(:artist) }
    let!(:favorite) { create(:user_artist_favorite, user: user, artist: artist) }

    context "ログイン済みのとき" do
      before { sign_in user, scope: :user }

      it "アーティストのお気に入りを削除し、JSONで200を返す" do
        expect {
          delete artist_favorite_path(artist), as: :json
        }.to change { user.user_artist_favorites.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          "artist_id" => artist.id,
          "favorited" => false
        )
      end
    end
  end
end
