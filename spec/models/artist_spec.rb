require "rails_helper"

RSpec.describe Artist, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリは未定義なので直接指定で有効" do
      expect(Artist.new(name: "Artist", published: true, uuid: SecureRandom.uuid)).to be_valid
    end

    it "nameは必須でユニーク" do
      create(:artist, name: "Unique Artist")
      dup = build(:artist, name: "Unique Artist")

      expect(dup).to be_invalid
    end

    it "spotify_artist_idは22桁Base62のみ許可" do
      ok = build(:artist, name: "OK", spotify_artist_id: "0OdUWJ0sBjDrqHygGUXeCF")
      ng = build(:artist, name: "NG", spotify_artist_id: "invalid")

      expect(ok).to be_valid
      expect(ng).to be_invalid
    end
  end

  describe "スコープ" do
    it ".published は公開のみ返す" do
      published = create(:artist, name: "Pub", published: true)
      hidden = create(:artist, name: "Hidden", published: false)

      expect(Artist.published).to include(published)
      expect(Artist.published).not_to include(hidden)
    end
  end

  describe "#to_param" do
    it "uuidを返す" do
      artist = create(:artist, name: "A")
      expect(artist.to_param).to eq(artist.uuid)
    end
  end
end
