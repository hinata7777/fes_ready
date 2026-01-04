require "rails_helper"

RSpec.describe "管理画面の出演枠一括登録", type: :request do
  let(:admin) { create(:user, role: :admin) }

  describe "POST /admin/stage_performances" do
    let(:festival_day) { create(:festival_day) }
    let(:stage) { create(:stage, festival: festival_day.festival) }
    let(:artist) { create(:artist) }

    before { sign_in admin, scope: :user }

    it "有効な行があれば出演枠を作成して一覧へ戻る" do
      params = {
        bulk: {
          festival_day_id: festival_day.id,
          stage_id: stage.id,
          entries: [
            {
              artist_id: artist.id,
              starts_at: "2025-01-01T12:00",
              ends_at: "2025-01-01T13:00",
              status: "draft",
              canceled: "0"
            }
          ]
        }
      }

      expect {
        post admin_stage_performances_path, params: params
      }.to change(StagePerformance, :count).by(1)

      expect(response).to redirect_to(admin_stage_performances_path)
    end

    it "有効な行がなければ作成せず422を返す" do
      params = {
        bulk: {
          festival_day_id: festival_day.id,
          stage_id: stage.id,
          entries: [
            {
              artist_id: "",
              starts_at: "",
              ends_at: "",
              status: "draft",
              canceled: "0"
            }
          ]
        }
      }

      expect {
        post admin_stage_performances_path, params: params
      }.not_to change(StagePerformance, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /admin/stage_performances/:id" do
    let(:festival_day) { create(:festival_day) }
    let(:stage) { create(:stage, festival: festival_day.festival) }
    let(:artist) { create(:artist) }
    let(:stage_performance) do
      create(:stage_performance, festival_day: festival_day, artist: artist, status: :draft)
    end

    before { sign_in admin, scope: :user }

    it "編集内容を更新できる" do
      params = {
        stage_performance: {
          stage_id: stage.id,
          starts_at: "2025-01-01T12:00",
          ends_at: "2025-01-01T13:00",
          status: "scheduled"
        }
      }

      patch admin_stage_performance_path(stage_performance), params: params

      expect(response).to redirect_to(admin_stage_performance_path(stage_performance))
      stage_performance.reload
      expect(stage_performance.stage_id).to eq(stage.id)
      expect(stage_performance.status).to eq("scheduled")
    end
  end
end
