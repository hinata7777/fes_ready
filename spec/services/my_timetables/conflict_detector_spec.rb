require "rails_helper"

RSpec.describe MyTimetables::ConflictDetector do
  describe ".call" do
    let(:festival_day) { create(:festival_day) }

    it "並び順がバラバラでも重複を検知できる" do
      first = create(
        :stage_performance,
        :scheduled,
        festival_day: festival_day,
        starts_at: festival_day.date.to_time.change(hour: 12),
        ends_at: festival_day.date.to_time.change(hour: 13)
      )
      second = create(
        :stage_performance,
        :scheduled,
        festival_day: festival_day,
        starts_at: festival_day.date.to_time.change(hour: 12, min: 30),
        ends_at: festival_day.date.to_time.change(hour: 13, min: 30)
      )
      third = create(
        :stage_performance,
        :scheduled,
        festival_day: festival_day,
        starts_at: festival_day.date.to_time.change(hour: 14),
        ends_at: festival_day.date.to_time.change(hour: 15)
      )

      result = described_class.call([ third, second, first ])

      expect(result.to_a).to match_array([ first.id, second.id ])
    end

    it "重複がない場合は空の集合を返す" do
      first = create(
        :stage_performance,
        :scheduled,
        festival_day: festival_day,
        starts_at: festival_day.date.to_time.change(hour: 10),
        ends_at: festival_day.date.to_time.change(hour: 11)
      )
      second = create(
        :stage_performance,
        :scheduled,
        festival_day: festival_day,
        starts_at: festival_day.date.to_time.change(hour: 11),
        ends_at: festival_day.date.to_time.change(hour: 12)
      )

      result = described_class.call([ second, first ])

      expect(result).to be_empty
    end
  end
end
