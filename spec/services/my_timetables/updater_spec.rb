require "rails_helper"

RSpec.describe MyTimetables::Updater do
  describe ".call" do
    let(:user) { create(:user) }
    let(:festival_day) { create(:festival_day) }
    let(:other_day) { create(:festival_day, festival: festival_day.festival, date: festival_day.date + 1.day) }
    let!(:existing_same_day_entry) do
      create(:user_timetable_entry, user: user, stage_performance: create(:stage_performance, :scheduled, festival_day: festival_day))
    end
    let!(:existing_other_day_entry) do
      create(:user_timetable_entry, user: user, stage_performance: create(:stage_performance, :scheduled, festival_day: other_day))
    end
    let!(:target_performance) { create(:stage_performance, :scheduled, festival_day: festival_day) }

    it "対象日の選択だけを置き換え、他の日の選択は残す" do
      described_class.call(
        user: user,
        festival_day: festival_day,
        stage_performance_ids: [ target_performance.id ]
      )

      same_day_ids = user.user_timetable_entries.joins(:stage_performance).where(stage_performances: { festival_day_id: festival_day.id }).pluck(:stage_performance_id)
      other_day_ids = user.user_timetable_entries.joins(:stage_performance).where(stage_performances: { festival_day_id: other_day.id }).pluck(:stage_performance_id)

      expect(same_day_ids).to match_array([ target_performance.id ])
      expect(other_day_ids).to match_array([ existing_other_day_entry.stage_performance_id ])
    end

    it "重複IDや他の日のIDは無視してユニークに登録する" do
      another_day_perf = create(:stage_performance, :scheduled)

      described_class.call(
        user: user,
        festival_day: festival_day,
        stage_performance_ids: [ target_performance.id, target_performance.id, another_day_perf.id, 999 ]
      )

      same_day_ids = user.user_timetable_entries.joins(:stage_performance).where(stage_performances: { festival_day_id: festival_day.id }).pluck(:stage_performance_id)
      expect(same_day_ids).to match_array([ target_performance.id ])
    end

    it "作成時に例外が起きたらトランザクションでロールバックされる" do
      allow_any_instance_of(UserTimetableEntry).to receive(:save!).and_raise(StandardError.new("boom"))

      expect {
        described_class.call(
          user: user,
          festival_day: festival_day,
          stage_performance_ids: [ target_performance.id ]
        )
      }.to raise_error(StandardError)

      # 例外前に削除された既存の当日分も、ロールバックで復元される
      same_day_ids = user.user_timetable_entries.joins(:stage_performance).where(stage_performances: { festival_day_id: festival_day.id }).pluck(:stage_performance_id)
      expect(same_day_ids).to include(existing_same_day_entry.stage_performance_id)
    end
  end
end
