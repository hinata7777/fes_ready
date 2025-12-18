require "rails_helper"

RSpec.describe "マイタイムテーブルのリクエスト", type: :request do
  let(:festival) { create(:festival) }
  let!(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }
  let!(:stage) { create(:stage, festival: festival) }
  let!(:stage_performance) do
    create(:stage_performance, :scheduled, festival_day: festival_day, stage: stage, artist: create(:artist))
  end

  describe "GET /festivals/:festival_id/my_timetable" do
    let(:owner) { create(:user) }
    let!(:entry) { create(:user_timetable_entry, user: owner, stage_performance: stage_performance) }

    it "ユーザーID付きで閲覧でき、200を返す" do
      get festival_my_timetable_path(festival, date: festival_day.date.to_s, user_id: owner.uuid)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /festivals/:festival_id/my_timetable/edit" do
    let(:user) { create(:user) }

    it "ログイン済みなら編集画面を表示できる" do
      sign_in user

      get edit_festival_my_timetable_path(festival, date: festival_day.date.to_s)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /festivals/:festival_id/my_timetable" do
    let(:user) { create(:user) }

    it "選択した公演を登録して詳細へリダイレクトする" do
      sign_in user

      expect {
        patch festival_my_timetable_path(festival, date: festival_day.date.to_s),
              params: { stage_performance_ids: [ stage_performance.id ] }
      }.to change { user.user_timetable_entries.count }.by(1)

      expect(response).to redirect_to(
        festival_my_timetable_path(festival, date: festival_day.date.to_s, user_id: user.uuid)
      )
    end
  end

  describe "DELETE /festivals/:festival_id/my_timetable" do
    let(:user) { create(:user) }
    let!(:entry) { create(:user_timetable_entry, user: user, stage_performance: stage_performance) }

    it "その日の選択を削除して一覧へリダイレクトする" do
      sign_in user

      expect {
        delete festival_my_timetable_path(festival, date: festival_day.date.to_s)
      }.to change {
        user.user_timetable_entries.joins(:stage_performance).where(stage_performances: { festival_day_id: festival_day.id }).count
      }.from(1).to(0)

      expect(response).to redirect_to(my_timetables_path)
    end
  end

  describe "GET /my_timetables" do
    let(:user) { create(:user) }
    let!(:entry) { create(:user_timetable_entry, user: user, stage_performance: stage_performance) }

    it "ログイン済みなら一覧を表示できる" do
      sign_in user

      get my_timetables_path

      expect(response).to have_http_status(:ok)
    end
  end
end
