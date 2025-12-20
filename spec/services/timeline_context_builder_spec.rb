require "rails_helper"

RSpec.describe TimelineContextBuilder do
  describe ".build" do
    let(:festival) { create(:festival, timezone: "Asia/Tokyo") }
    let(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }

    it "公演時間からタイムラインの開始・終了を決め、1時間刻みのマーカーを返す" do
      stage = create(:stage, festival: festival)
      create(:stage_performance, :scheduled, festival_day: festival_day, stage: stage,
             starts_at: festival_day.date.to_time.change(hour: 12), ends_at: festival_day.date.to_time.change(hour: 13))

      result = described_class.build(festival: festival, selected_day: festival_day, timezone: ActiveSupport::TimeZone["Asia/Tokyo"])

      expect(result.timeline_start.hour).to eq(12)
      expect(result.timeline_end.hour).to eq(13)
      expect(result.time_markers.map(&:hour)).to include(12, 13)
    end

    it "終了時刻が開始より前なら翌日に補正してタイムラインを作る（徹夜跨ぎ）" do
      # 22:00開始 02:00終了（同日指定だが内部で+1日される）
      festival_day.update!(
        start_at: festival_day.date.to_time.change(hour: 22),
        end_at: festival_day.date.to_time.change(hour: 2)
      )

      result = described_class.build(festival: festival, selected_day: festival_day, timezone: ActiveSupport::TimeZone["Asia/Tokyo"])

      expect(result.timeline_start.hour).to eq(22)
      # 翌日の02:00になるので日付は+1、hourは2のまま
      expect(result.timeline_end.hour).to eq(2)
      expect(result.timeline_end.to_date).to eq(festival_day.date + 1.day)
      expect(result.time_markers.first.hour).to eq(22)
      expect(result.time_markers.last.hour).to eq(2)
    end

    it "公演が無い場合はデフォルトの開始(9時)と8時間後の終了になる" do
      result = described_class.build(festival: festival, selected_day: festival_day, timezone: ActiveSupport::TimeZone["Asia/Tokyo"])
      expect(result.timeline_start.hour).to eq(9)
      expect(result.timeline_end.hour).to eq(17)
    end

    it "開始時刻に分が含まれていてもマーカーが正しく丸められる" do
      festival_day.update!(start_at: festival_day.date.to_time.change(hour: 12, min: 30))
      result = described_class.build(festival: festival, selected_day: festival_day, timezone: ActiveSupport::TimeZone["Asia/Tokyo"])

      expect(result.timeline_start.min).to eq(30)
      # 最初のマーカーは次の正時から
      expect(result.time_markers.first.min).to eq(30)
      expect(result.time_markers.second.min).to eq(0)
    end
  end
end
