require "rails_helper"

RSpec.describe FestivalDay, type: :model do
  describe "#finished?" do
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
end
