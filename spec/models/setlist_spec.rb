require "rails_helper"

RSpec.describe Setlist, type: :model do
  describe "バリデーション" do
    it "出演枠があれば有効" do
      expect(build(:setlist)).to be_valid
    end

    it "出演枠は必須" do
      setlist = build(:setlist, stage_performance: nil)
      expect(setlist).to be_invalid
    end

    it "出演枠ごとに1つだけ持てる" do
      perf = create(:stage_performance)
      create(:setlist, stage_performance: perf)

      dup = build(:setlist, stage_performance: perf)
      expect(dup).to be_invalid
    end
  end

  describe "#to_param" do
    it "uuidがあればuuidを返す" do
      setlist = create(:setlist)
      expect(setlist.to_param).to eq(setlist.uuid)
    end
  end
end
