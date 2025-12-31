require "rails_helper"

RSpec.describe Artists::FavoritesQuery do
  describe ".call" do
    it "お気に入り済みのアーティストだけ返す" do
      user = create(:user)
      artist = create(:artist, name: "Artist A")
      other_artist = create(:artist, name: "Artist B")
      create(:user_artist_favorite, user: user, artist: artist)

      result = described_class.call(user: user)

      expect(result).to contain_exactly(artist)
      expect(result).not_to include(other_artist)
    end

    it "名前順で返す" do
      user = create(:user)
      artist_b = create(:artist, name: "B Artist")
      artist_a = create(:artist, name: "A Artist")
      create(:user_artist_favorite, user: user, artist: artist_b)
      create(:user_artist_favorite, user: user, artist: artist_a)

      result = described_class.call(user: user)

      expect(result.map(&:name)).to eq([ "A Artist", "B Artist" ])
    end
  end
end
