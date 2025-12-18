require "rails_helper"

RSpec.describe FestivalFestivalTag, type: :model do
  describe "バリデーション" do
    it "フェスとタグがあれば有効" do
      expect(build(:festival_festival_tag)).to be_valid
    end

    it "フェスは必須" do
      record = build(:festival_festival_tag, festival: nil)
      expect(record).to be_invalid
    end

    it "タグは必須" do
      record = build(:festival_festival_tag, festival_tag: nil)
      expect(record).to be_invalid
    end
  end
end
