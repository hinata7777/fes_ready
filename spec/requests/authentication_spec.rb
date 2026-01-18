require "rails_helper"
require "omniauth"

RSpec.describe "認証のリクエスト", type: :request do
  describe "PATCH /users" do
    let(:user) { create(:user, nickname: "旧ニックネーム") }

    before { sign_in user, scope: :user }

    it "パスワードなしでプロフィール更新できる" do
      patch user_registration_path, params: { user: { nickname: "新ニックネーム" } }

      expect(response).to have_http_status(:see_other)
      expect(user.reload.nickname).to eq("新ニックネーム")
    end

    it "パスワード変更は現在のパスワードが必要" do
      patch user_registration_path, params: {
        user: { password: "newpass123", password_confirmation: "newpass123" }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?("newpass123")).to be(false)
    end
  end

  describe "DELETE /users" do
    let!(:user) { create(:user) }

    before { sign_in user, scope: :user }

    it "アカウント退会後にログアウトしトップへ戻る" do
      expect {
        delete user_registration_path
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("退会しました。ご利用ありがとうございました。")

      get mypage_dashboard_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /users/auth/google_oauth2/callback" do
    around do |example|
      OmniAuth.config.test_mode = true
      example.run
    ensure
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      Rails.application.env_config["omniauth.auth"] = nil
    end

    it "Google認証でユーザーを作成してログインする" do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "12345",
        info: { email: "test@example.com", name: "Test User" }
      )
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

      expect {
        get "/users/auth/google_oauth2/callback"
      }.to change(User, :count).by(1)

      user = User.find_by(email: "test@example.com")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("12345")
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /users/auth/failure" do
    it "OAuth失敗時はトップへリダイレクトする" do
      get "/users/auth/failure"

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /users/password" do
    before { ActionMailer::Base.deliveries.clear }

    it "ログイン済みなら自分宛に送信しマイページへリダイレクトする" do
      user = create(:user)
      sign_in user, scope: :user

      post user_password_path, params: { user: { email: "ignored@example.com" } }

      expect(response).to redirect_to(mypage_dashboard_path)
      expect(ActionMailer::Base.deliveries).not_to be_empty
      expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    end

    it "未ログインでも送信できる" do
      user = create(:user)

      post user_password_path, params: { user: { email: user.email } }

      expect(response).to have_http_status(:found)
      expect(ActionMailer::Base.deliveries).not_to be_empty
      expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    end

    it "未登録メールなら送信されない" do
      post user_password_path, params: { user: { email: "unknown@example.com" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "POST /users" do
    it "正常な入力なら作成される" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123",
            nickname: "newuser"
          }
        }
      }.to change(User, :count).by(1)

      user = User.find_by(email: "newuser@example.com")
      expect(user).not_to be_nil
      expect(user.uid).to be_nil
      expect(response).to have_http_status(:see_other)
    end

    it "バリデーションエラーなら作成されない" do
      expect {
        post user_registration_path, params: { user: { email: "", password: "short", nickname: "" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
