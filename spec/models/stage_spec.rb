require "rails_helper"

RSpec.describe Stage, type: :model do
  describe "バリデーション" do
    it "名前とフェスがあれば有効" do
      expect(build(:stage)).to be_valid
    end

    it "名前は必須" do
      stage = build(:stage, name: nil)
      expect(stage).to be_invalid
    end

    it "色キーは定義済みのみ許可" do
      ok = build(:stage, color_key: "red")
      ng = build(:stage, color_key: "unknown")

      expect(ok).to be_valid
      expect(ng).to be_invalid
    end
  end
end
