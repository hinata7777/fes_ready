require "rails_helper"

RSpec.describe "マイページのリクエスト", type: :request do
  describe "GET /mypage" do
    it "未ログインならログイン画面へリダイレクトする" do
      get mypage_dashboard_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みなら200を返す" do
      user = create(:user)
      sign_in user, scope: :user

      get mypage_dashboard_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mypage/festivals" do
    it "未ログインならログイン画面へリダイレクトする" do
      get mypage_favorite_festivals_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みなら200を返す" do
      user = create(:user)
      create(:user_festival_favorite, user: user)
      sign_in user, scope: :user

      get mypage_favorite_festivals_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /mypage/artists" do
    it "未ログインならログイン画面へリダイレクトする" do
      get mypage_favorite_artists_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みなら200を返す" do
      user = create(:user)
      create(:user_artist_favorite, user: user)
      sign_in user, scope: :user

      get mypage_favorite_artists_path
      expect(response).to have_http_status(:ok)
    end
  end
end
