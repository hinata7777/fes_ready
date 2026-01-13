require "rails_helper"

RSpec.describe Admin::PackingListForm do
  describe "#save" do
    it "テンプレートとして保存しitem_attributesを無視する" do
      item = create(:template_item)

      params = ActionController::Parameters.new(
        packing_list: {
          title: "テンプレ",
          festival_day_id: nil,
          packing_list_items_attributes: {
            "0" => {
              item_id: item.id,
              position: "0",
              note: "メモ",
              item_attributes: {
                name: "無視される"
              }
            }
          }
        }
      )

      form = described_class.new(params: params)

      expect { form.save }.to change(PackingList, :count).by(1)
        .and change(Item, :count).by(0)
      expect(form.packing_list.template).to be(true)
      expect(form.packing_list.user).to be_nil
    end
  end
end
