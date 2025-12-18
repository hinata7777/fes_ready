require "rails_helper"

RSpec.describe FestivalTag, type: :model do
  describe "バリデーション" do
    it "名前があれば有効" do
      expect(build(:festival_tag)).to be_valid
    end

    it "名前は必須でユニーク" do
      create(:festival_tag, name: "Rock")
      dup = build(:festival_tag, name: "Rock")

      expect(dup).to be_invalid
    end
  end
end
