require "rails_helper"

RSpec.describe FestivalDay, type: :model do
  describe "開催済み判定" do
    it "フェスの終了日が今日以降ならfalse" do
      festival = create(:festival, start_date: Date.current, end_date: Date.current + 1)
      day = build(:festival_day, festival: festival, date: festival.start_date)

      expect(day.finished?(Date.current)).to be false
    end

    it "フェスの終了日が今日より前ならtrue" do
      festival = create(:festival, start_date: Date.current - 10, end_date: Date.current - 5)
      day = build(:festival_day, festival: festival, date: festival.start_date)

      expect(day.finished?(Date.current)).to be true
    end
  end

  describe "日付のバリデーション" do
    it "日付は必須" do
      day = build(:festival_day, date: nil)
      expect(day).to be_invalid
    end

    it "同一フェス内では日付ユニーク" do
      festival = create(:festival)
      create(:festival_day, festival: festival, date: festival.start_date)
      dup = build(:festival_day, festival: festival, date: festival.start_date)

      expect(dup).to be_invalid
    end
  end
end
