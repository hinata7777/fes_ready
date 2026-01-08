require "rails_helper"

RSpec.describe "セットリスト一覧", type: :request do
  let(:festival) do
    create(
      :festival,
      start_date: 10.days.ago.to_date,
      end_date: 9.days.ago.to_date,
      timezone: "Asia/Tokyo"
    )
  end

  let(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }

  describe "GET /festivals/:festival_id/setlists" do
    it "過去フェスの一覧を表示できる" do
      stage = create(:stage, festival: festival)
      performance = create(:stage_performance, :scheduled, festival_day: festival_day, stage: stage)
      create(:setlist, stage_performance: performance)

      get festival_setlists_path(festival, date: festival_day.date.to_s)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("#{festival.name} のセットリスト")
      expect(response.body).to include(performance.artist.name)
    end

    it "出演枠がない場合は空メッセージを表示する" do
      get festival_setlists_path(festival, date: festival_day.date.to_s)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("表示できる出演枠がありません。")
    end
  end
end
