require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリなら有効" do
      expect(build(:user)).to be_valid
    end

    it "nicknameは必須で10文字以内" do
      user = build(:user, nickname: nil)
      expect(user).to be_invalid

      user.nickname = "a" * 11
      expect(user).to be_invalid
    end

    it "emailはユニーク" do
      email = "dup@example.com"
      create(:user, email: email)
      dup = build(:user, email: email)

      expect(dup).to be_invalid
    end

    it "uidはproviderごとにユニーク" do
      create(:user, provider: "google", uid: "123")
      dup = build(:user, provider: "google", uid: "123")

      expect(dup).to be_invalid
    end
  end

  describe "#to_param" do
    it "uuidを返す" do
      user = create(:user)
      expect(user.to_param).to eq(user.uuid)
    end
  end
end
