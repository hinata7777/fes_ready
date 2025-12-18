require "rails_helper"

RSpec.describe StagePerformance, type: :model do
  describe "バリデーション" do
    it "draftならステージ/時間なしでも有効" do
      expect(build(:stage_performance, status: :draft)).to be_valid
    end

    it "scheduledならステージと時間が必須" do
      perf = build(:stage_performance, :scheduled, stage: nil, starts_at: nil, ends_at: nil)
      expect(perf).to be_invalid
      expect(perf.errors[:stage]).to be_present
      expect(perf.errors[:starts_at]).to be_present
      expect(perf.errors[:ends_at]).to be_present
    end

    it "終了時刻は開始後でないと無効" do
      perf = build(:stage_performance, :scheduled,
                   starts_at: Time.zone.now.change(hour: 12),
                   ends_at: Time.zone.now.change(hour: 11))
      expect(perf).to be_invalid
      expect(perf.errors[:ends_at]).to include("は開始より後にしてください")
    end
  end
end
