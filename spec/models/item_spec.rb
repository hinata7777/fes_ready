require "rails_helper"

RSpec.describe Item, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリなら有効" do
      expect(build(:item)).to be_valid
    end

    it "nameは必須" do
      item = build(:item, name: nil)
      expect(item).to be_invalid
      expect(item.errors[:name]).to be_present
    end

    it "nameは100文字以内" do
      item = build(:item, name: "a" * 101)
      expect(item).to be_invalid
    end

    it "templateでなければuserが必須" do
      item = build(:item, user: nil, template: false)
      expect(item).to be_invalid
      expect(item.errors[:user_id]).to be_present
    end

    it "templateならuserなしでよい" do
      expect(build(:template_item)).to be_valid
    end

    it "templateフラグは真偽値のみ" do
      item = build(:item, template: nil)
      expect(item).to be_invalid
    end
  end

  describe "スコープ" do
    it ".templates はテンプレートのみ返す" do
      template = create(:template_item)
      non_template = create(:item)

      expect(Item.templates).to include(template)
      expect(Item.templates).not_to include(non_template)
    end

    it ".owned_by は指定ユーザーのアイテムのみ返す" do
      user = create(:user)
      owned = create(:item, user: user)
      other = create(:item)

      expect(Item.owned_by(user)).to contain_exactly(owned)
      expect(Item.owned_by(user)).not_to include(other)
    end
  end
end
