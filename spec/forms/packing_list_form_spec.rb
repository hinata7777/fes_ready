require "rails_helper"

RSpec.describe PackingListForm do
  describe "#initialize" do
    it "template_idがあればテンプレート内容を反映する" do
      user = create(:user)
      template_list = create(:template_packing_list, title: "テンプレート")
      template_item = create(:template_item)
      create(:packing_list_item, packing_list: template_list, item: template_item, position: 1, note: "note")

      form = described_class.new(user: user, template_id: template_list.id)

      expect(form.packing_list.title).to eq("テンプレート")
      expect(form.packing_list.packing_list_items.size).to eq(1)
      expect(form.packing_list.packing_list_items.first.item_id).to eq(template_item.id)
    end
  end

  describe "#save" do
    it "item_attributesがあれば新規アイテムを作成して所有者を設定する" do
      user = create(:user)

      params = ActionController::Parameters.new(
        packing_list: {
          title: "新しいリスト",
          festival_day_id: nil,
          packing_list_items_attributes: {
            "0" => {
              position: "0",
              note: "メモ",
              item_attributes: {
                name: "新規アイテム",
                description: "説明",
                category: "gear",
                ignored: "nope"
              }
            }
          }
        }
      )

      form = described_class.new(user: user, params: params)

      expect { form.save }.to change(PackingList, :count).by(1)
      expect(form.packing_list.items.first.name).to eq("新規アイテム")
      expect(form.packing_list.items.first.user).to eq(user)
      expect(form.packing_list.items.first.template).to be(false)
    end

    it "同名のテンプレートアイテムがあれば再利用する" do
      user = create(:user)
      template_item = create(:template_item, name: "テント")

      params = ActionController::Parameters.new(
        packing_list: {
          title: "持ち物",
          packing_list_items_attributes: {
            "0" => {
              position: "0",
              note: "",
              item_attributes: {
                name: "テント"
              }
            }
          }
        }
      )

      form = described_class.new(user: user, params: params)

      expect { form.save }.not_to change(Item, :count)
      expect(form.packing_list.items.first.id).to eq(template_item.id)
    end
  end
end
