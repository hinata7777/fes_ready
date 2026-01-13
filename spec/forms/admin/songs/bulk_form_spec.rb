require "rails_helper"

RSpec.describe Admin::Songs::BulkForm do
  describe "#save" do
    it "入力行がない場合にエラーになる" do
      form = described_class.new({})

      expect(form.save).to be(false)
      expect(form.errors.full_messages).to include("1行以上入力してください。")
      expect(form.bulk_entries.size).to eq(described_class::ENTRY_LIMIT)
    end

    it "入力が有効なら曲を作成する" do
      artist = create(:artist)

      params = {
        entries: [
          { name: "Song A", spotify_id: nil, artist_id: artist.id }
        ]
      }

      form = described_class.new(params)

      expect { form.save }.to change(Song, :count).by(1)
      expect(form.created_count).to eq(1)
    end

    it "空行や削除行は無視する" do
      artist = create(:artist)

      params = {
        entries: [
          { name: "", spotify_id: nil, artist_id: "" },
          { name: "Song A", spotify_id: "0OdUWJ0sBjDrqHygGUXeCF", artist_id: artist.id, _destroy: "0" },
          { name: "Song B", spotify_id: "0OdUWJ0sBjDrqHygGUXeCF", artist_id: artist.id, _destroy: "1" }
        ]
      }

      form = described_class.new(params)

      expect { form.save }.to change(Song, :count).by(1)
      expect(form.created_count).to eq(1)
    end
  end
end
