require "rails_helper"

RSpec.describe "Favoritable", type: :model do
  describe ".favorited_by" do
    it "artistでお気に入り済みのみ返す" do
      user = create(:user)
      other_user = create(:user)
      artist = create(:artist)
      other_artist = create(:artist)
      create(:user_artist_favorite, user: user, artist: artist)
      create(:user_artist_favorite, user: other_user, artist: other_artist)

      expect(Artist.favorited_by(user)).to contain_exactly(artist)
    end

    it "festivalでお気に入り済みのみ返す" do
      user = create(:user)
      other_user = create(:user)
      festival = create(:festival)
      other_festival = create(:festival)
      create(:user_festival_favorite, user: user, festival: festival)
      create(:user_festival_favorite, user: other_user, festival: other_festival)

      expect(Festival.favorited_by(user)).to contain_exactly(festival)
    end
  end

  describe "#favorited_by?" do
    it "artistのお気に入り状態を判定できる" do
      user = create(:user)
      other_user = create(:user)
      artist = create(:artist)
      create(:user_artist_favorite, user: user, artist: artist)

      expect(artist.favorited_by?(user)).to be(true)
      expect(artist.favorited_by?(other_user)).to be(false)
      expect(artist.favorited_by?(nil)).to be(false)
    end

    it "festivalのお気に入り状態を判定できる" do
      user = create(:user)
      other_user = create(:user)
      festival = create(:festival)
      create(:user_festival_favorite, user: user, festival: festival)

      expect(festival.favorited_by?(user)).to be(true)
      expect(festival.favorited_by?(other_user)).to be(false)
      expect(festival.favorited_by?(nil)).to be(false)
    end
  end
end
