require "rails_helper"

RSpec.describe Song, type: :model do
  describe "バリデーション" do
    it "アーティストと名前があれば有効" do
      expect(build(:song)).to be_valid
    end

    it "名前は必須で正規化後も必須" do
      song = build(:song, name: nil)
      expect(song).to be_invalid
    end

    it "同一アーティスト内で正規化名がユニーク" do
      artist = create(:artist)
      create(:song, artist: artist, name: "Hello")
      dup = build(:song, artist: artist, name: "hello")

      expect(dup).to be_invalid
    end

    it "spotify_idは22桁Base62のみ許可" do
      ok = build(:song, spotify_id: "0OdUWJ0sBjDrqHygGUXeCF")
      ng = build(:song, spotify_id: "invalid")

      expect(ok).to be_valid
      expect(ng).to be_invalid
    end
  end
end
