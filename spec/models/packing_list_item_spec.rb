require "rails_helper"

RSpec.describe PackingListItem, type: :model do
  describe "バリデーション" do
    it "デフォルトのファクトリなら有効" do
      expect(build(:packing_list_item)).to be_valid
    end

    it "同一リスト内でitemはユニーク" do
      packing_list = create(:packing_list)
      item = create(:item)
      create(:packing_list_item, packing_list: packing_list, item: item)

      duplicate = build(:packing_list_item, packing_list: packing_list, item: item)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:item_id]).to be_present
    end

    it "checkedは真偽値のみ" do
      pli = build(:packing_list_item, checked: nil)
      expect(pli).to be_invalid
    end

    it "positionは0以上の整数" do
      negative = build(:packing_list_item, position: -1)
      decimal = build(:packing_list_item, position: 1.5)

      expect(negative).to be_invalid
      expect(decimal).to be_invalid
    end
  end
end
