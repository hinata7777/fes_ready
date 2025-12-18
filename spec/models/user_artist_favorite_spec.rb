require "rails_helper"

RSpec.describe UserArtistFavorite, type: :model do
  describe "バリデーション" do
    it "ユーザーとアーティストがあれば有効" do
      expect(build(:user_artist_favorite)).to be_valid
    end

    it "ユーザーは必須" do
      fav = build(:user_artist_favorite, user: nil)
      expect(fav).to be_invalid
    end

    it "アーティストは必須" do
      fav = build(:user_artist_favorite, artist: nil)
      expect(fav).to be_invalid
    end

    it "同じ組み合わせは重複不可" do
      user = create(:user)
      artist = create(:artist)
      create(:user_artist_favorite, user: user, artist: artist)

      dup = build(:user_artist_favorite, user: user, artist: artist)
      expect(dup).to be_invalid
    end
  end
end
