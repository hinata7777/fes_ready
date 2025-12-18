require "rails_helper"

RSpec.describe SetlistSong, type: :model do
  describe "バリデーション" do
    it "セットリストと曲があれば有効" do
      expect(build(:setlist_song)).to be_valid
    end

    it "セットリストは必須" do
      record = build(:setlist_song, setlist: nil)
      expect(record).to be_invalid
    end

    it "曲は必須" do
      record = build(:setlist_song, song: nil)
      expect(record).to be_invalid
    end

    it "positionは1以上の整数" do
      negative = build(:setlist_song, position: 0)
      float = build(:setlist_song, position: 1.5)

      expect(negative).to be_invalid
      expect(float).to be_invalid
    end

    it "同じセットリスト内でpositionはユニーク" do
      setlist = create(:setlist)
      create(:setlist_song, setlist: setlist, position: 1)

      dup = build(:setlist_song, setlist: setlist, position: 1)
      expect(dup).to be_invalid
    end
  end
end
