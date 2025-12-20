require "rails_helper"

RSpec.describe "管理画面のリクエスト", type: :request do
  describe "GET /admin" do
    it "一般ユーザーはリダイレクトされる" do
      user = create(:user)
      sign_in user, scope: :user

      get admin_root_path
      expect(response).to redirect_to(root_path)
    end

    it "管理者は200を返す" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      get admin_root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/festival_tags" do
    it "一般ユーザーは作成できずリダイレクトされる" do
      user = create(:user)
      sign_in user, scope: :user

      expect {
        post admin_festival_tags_path, params: { festival_tag: { name: "ロック" } }
      }.not_to change(FestivalTag, :count)

      expect(response).to redirect_to(root_path)
    end

    it "管理者は作成できる" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_festival_tags_path, params: { festival_tag: { name: "ロック" } }
      }.to change(FestivalTag, :count).by(1)

      expect(response).to redirect_to(admin_festival_tags_path)
    end

    it "管理者でもバリデーションエラーなら422を返す" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_festival_tags_path, params: { festival_tag: { name: "" } }
      }.not_to change(FestivalTag, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /admin/artists" do
    let(:valid_params) { { artist: { name: "管理用アーティスト", published: true } } }

    it "一般ユーザーは作成できずリダイレクトされる" do
      user = create(:user)
      sign_in user, scope: :user

      expect {
        post admin_artists_path, params: valid_params
      }.not_to change(Artist, :count)

      expect(response).to redirect_to(root_path)
    end

    it "管理者は作成できる" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_artists_path, params: valid_params
      }.to change(Artist, :count).by(1)

      expect(response).to redirect_to(admin_artists_path)
    end

    it "管理者でもバリデーションエラーなら422を返す" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_artists_path, params: { artist: { name: "" } }
      }.not_to change(Artist, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /admin/festivals" do
    let(:valid_params) do
      {
        festival: {
          name: "管理用フェス",
          slug: "admin-fes",
          start_date: Date.current,
          end_date: Date.current + 1.day,
          timezone: "Asia/Tokyo"
        }
      }
    end

    it "一般ユーザーは作成できずリダイレクトされる" do
      user = create(:user)
      sign_in user, scope: :user

      expect {
        post admin_festivals_path, params: valid_params
      }.not_to change(Festival, :count)

      expect(response).to redirect_to(root_path)
    end

    it "管理者は作成できる" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_festivals_path, params: valid_params
      }.to change(Festival, :count).by(1)

      expect(response).to redirect_to(setup_admin_festival_path(Festival.last))
    end

    it "管理者でもバリデーションエラーなら422を返す" do
      admin = create(:user, role: :admin)
      sign_in admin, scope: :user

      expect {
        post admin_festivals_path, params: { festival: valid_params[:festival].merge(name: "", end_date: Date.current - 1.day) }
      }.not_to change(Festival, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
