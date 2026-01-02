require "rails_helper"

RSpec.describe "持ち物リスト項目のリクエスト", type: :request do
  let(:user) { create(:user) }
  let(:packing_list) { create(:packing_list, user: user) }
  let(:item) { create(:item, user: user) }

  describe "PATCH /packing_lists/:packing_list_id/packing_list_items/:id" do
    let!(:packing_list_item) { create(:packing_list_item, packing_list: packing_list, item: item, note: "旧メモ", position: 0) }

    it "チェック状態を更新してリストへリダイレクトする" do
      sign_in user, scope: :user

      patch packing_list_packing_list_item_path(packing_list, packing_list_item),
            params: { packing_list_item: { checked: true } }

      expect(response).to redirect_to(packing_list_path(packing_list))
      packing_list_item.reload
      expect(packing_list_item.checked).to be(true)
    end

    it "更新に失敗したら内容は変わらない" do
      sign_in user, scope: :user

      patch packing_list_packing_list_item_path(packing_list, packing_list_item),
            params: { packing_list_item: { position: -1 } }

      expect(response).to redirect_to(packing_list_path(packing_list))
      expect(packing_list_item.reload.position).to eq(0)
    end

    it "他人のリストは404を返す" do
      other_user = create(:user)
      sign_in other_user, scope: :user

      patch packing_list_packing_list_item_path(packing_list, packing_list_item),
            params: { packing_list_item: { note: "侵入" } }

      expect(response).to have_http_status(:not_found)
      expect(packing_list_item.reload.note).to eq("旧メモ")
    end
  end
end
