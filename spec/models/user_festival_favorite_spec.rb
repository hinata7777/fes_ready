require "rails_helper"

RSpec.describe UserFestivalFavorite, type: :model do
  describe "バリデーション" do
    it "ユーザーとフェスがあれば有効" do
      expect(build(:user_festival_favorite)).to be_valid
    end

    it "ユーザーは必須" do
      fav = build(:user_festival_favorite, user: nil)
      expect(fav).to be_invalid
    end

    it "フェスは必須" do
      fav = build(:user_festival_favorite, festival: nil)
      expect(fav).to be_invalid
    end

    it "同じ組み合わせは重複不可" do
      user = create(:user)
      festival = create(:festival)
      create(:user_festival_favorite, user: user, festival: festival)

      dup = build(:user_festival_favorite, user: user, festival: festival)
      expect(dup).to be_invalid
    end
  end
end
