require "rails_helper"

RSpec.describe UserTimetableEntry, type: :model do
  describe "バリデーション" do
    it "ユーザーと出演枠があれば有効" do
      expect(build(:user_timetable_entry)).to be_valid
    end

    it "ユーザーは必須" do
      entry = build(:user_timetable_entry, user: nil)
      expect(entry).to be_invalid
    end

    it "出演枠は必須" do
      entry = build(:user_timetable_entry, stage_performance: nil)
      expect(entry).to be_invalid
    end

    it "同じ公演はユーザーごとに一意" do
      user = create(:user)
      perf = create(:stage_performance, :scheduled)
      create(:user_timetable_entry, user: user, stage_performance: perf)

      dup = build(:user_timetable_entry, user: user, stage_performance: perf)
      expect(dup).to be_invalid
    end
  end
end
