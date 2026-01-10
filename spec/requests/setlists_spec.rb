require "rails_helper"

RSpec.describe "セットリスト一覧", type: :request do
  let(:festival) do
    create(
      :festival,
      start_date: Date.current,
      end_date: 1.day.from_now.to_date,
      timezone: "Asia/Tokyo"
    )
  end

  let(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }

  describe "GET /festivals/:festival_id/setlists" do
    it "開始日が今日以降のフェスの一覧を表示できる" do
      stage = create(:stage, festival: festival)
      performance = create(:stage_performance, :scheduled, festival_day: festival_day, stage: stage)
      create(:setlist, stage_performance: performance)

      get festival_setlists_path(festival, date: festival_day.date.to_s)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("#{festival.name} のセットリスト")
      expect(response.body).to include(performance.artist.name)
    end

    it "セットリストがない場合は404になる" do
      get festival_setlists_path(festival, date: festival_day.date.to_s)

      expect(response).to have_http_status(:not_found)
    end
  end
end
