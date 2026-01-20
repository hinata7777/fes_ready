require "rails_helper"

RSpec.describe Festival, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリなら有効" do
      expect(build(:festival)).to be_valid
    end

    it "必須項目が欠けると無効" do
      festival = build(:festival, name: nil, slug: nil, start_date: nil, end_date: nil, timezone: nil)
      expect(festival).to be_invalid
      expect(festival.errors[:name]).to be_present
      expect(festival.errors[:slug]).to be_present
      expect(festival.errors[:start_date]).to be_present
      expect(festival.errors[:end_date]).to be_present
      expect(festival.errors[:timezone]).to be_present
    end

    it "slugはユニーク" do
      create(:festival, slug: "unique-slug")
      dup = build(:festival, slug: "unique-slug")

      expect(dup).to be_invalid
    end

    it "開始日より前の終了日は不可" do
      festival = build(:festival, start_date: Date.current, end_date: Date.current - 1)
      expect(festival).to be_invalid
      expect(festival.errors[:end_date]).to include("は開始日以降にしてください")
    end

    it "公式URLはhttp/httpsのみ許可" do
      ok = build(:festival, official_url: "https://example.com")
      ng = build(:festival, official_url: "ftp://example.com")

      expect(ok).to be_valid
      expect(ng).to be_invalid
    end
  end

  describe "#to_param" do
    it "slugがあればslugを返す" do
      festival = build(:festival, slug: "awesome-fes")
      expect(festival.to_param).to eq("awesome-fes")
    end
  end

  describe "#artists_for_day" do
    it "非公開アーティストを含めない" do
      festival = create(:festival)
      festival_day = create(:festival_day, festival: festival)
      published_artist = create(:artist, published: true)
      unpublished_artist = create(:artist, published: false)

      create(:stage_performance, festival_day: festival_day, artist: published_artist)
      create(:stage_performance, festival_day: festival_day, artist: unpublished_artist)

      result = festival.artists_for_day(festival_day)

      expect(result).to include(published_artist)
      expect(result).not_to include(unpublished_artist)
    end
  end
end
