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

  describe "PATCH /admin/festivals/:id" do
    let(:admin) { create(:user, role: :admin) }
    let(:festival) { create(:festival) }

    before do
      sign_in admin, scope: :user
    end

    it "基本情報を更新できる" do
      patch admin_festival_path(festival), params: { festival: { name: "更新後フェス" } }

      expect(response).to redirect_to(admin_festival_path(festival))
      expect(festival.reload.name).to eq("更新後フェス")
    end

    it "日程・ステージをネスト更新できる" do
      params = {
        festival: {
          festival_days_attributes: {
            "0" => { date: festival.start_date }
          },
          stages_attributes: {
            "0" => { name: "Main Stage" }
          }
        }
      }

      expect {
        patch admin_festival_path(festival), params: params
      }.to change(FestivalDay, :count).by(1)
        .and change(Stage, :count).by(1)

      expect(response).to redirect_to(admin_festival_path(festival))
    end
  end
end
