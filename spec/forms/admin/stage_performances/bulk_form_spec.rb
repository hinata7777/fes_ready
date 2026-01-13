require "rails_helper"

RSpec.describe Admin::StagePerformances::BulkForm do
  describe "#save" do
    it "開催日・ステージ・入力行がない場合にエラーになる" do
      form = described_class.new({})

      expect(form.save).to be(false)
      expect(form.errors.full_messages).to include("開催日を選択してください。", "ステージを選択してください。", "1行以上入力してください。")
      expect(form.bulk_entries.size).to eq(described_class::ENTRY_LIMIT)
    end

    it "開催日またはステージがない場合にエラーになる" do
      artist = create(:artist)

      form = described_class.new(entries: [ { artist_id: artist.id } ])

      expect(form.save).to be(false)
      expect(form.errors.full_messages).to include("開催日を選択してください。", "ステージを選択してください。")
    end

    it "入力が有効なら出演枠を作成する" do
      festival_day = create(:festival_day)
      stage = create(:stage, festival: festival_day.festival)
      artist = create(:artist)

      params = {
        festival_day_id: festival_day.id,
        stage_id: stage.id,
        entries: [
          { artist_id: artist.id, starts_at: nil, ends_at: nil, status: "draft", canceled: "0" }
        ]
      }

      form = described_class.new(params)

      expect { form.save }.to change(StagePerformance, :count).by(1)
      expect(form.created_count).to eq(1)
    end

    it "空行は無視して入力行だけ作成する" do
      festival_day = create(:festival_day)
      stage = create(:stage, festival: festival_day.festival)
      artist = create(:artist)

      params = {
        festival_day_id: festival_day.id,
        stage_id: stage.id,
        entries: [
          { artist_id: nil, starts_at: nil, ends_at: nil, status: "draft", canceled: "0" },
          { artist_id: artist.id, starts_at: nil, ends_at: nil, status: "draft", canceled: "0" }
        ]
      }

      form = described_class.new(params)

      expect { form.save }.to change(StagePerformance, :count).by(1)
      expect(form.created_count).to eq(1)
    end

    it "canceledがチェックされていればtrueになる" do
      festival_day = create(:festival_day)
      stage = create(:stage, festival: festival_day.festival)
      artist = create(:artist)

      params = {
        festival_day_id: festival_day.id,
        stage_id: stage.id,
        entries: [
          { artist_id: artist.id, starts_at: nil, ends_at: nil, status: "draft", canceled: "1" }
        ]
      }

      form = described_class.new(params)

      expect(form.save).to be(true)
      expect(StagePerformance.last.canceled).to be(true)
    end
  end
end
