require "rails_helper"

RSpec.describe "持ち物リスト項目のリクエスト", type: :request do
  let(:user) { create(:user) }
  let(:packing_list) { create(:packing_list, user: user) }
  let(:item) { create(:item, user: user) }

  describe "POST /packing_lists/:packing_list_id/packing_list_items" do
    context "ログイン済みのとき" do
      before { sign_in user, scope: :user }

      it "項目を追加してリストへリダイレクトする" do
        expect {
          post packing_list_packing_list_items_path(packing_list),
               params: { packing_list_item: { item_id: item.id, note: "メモ", position: 1 } }
        }.to change { packing_list.packing_list_items.count }.by(1)

        expect(response).to redirect_to(packing_list_path(packing_list))
        created_item = packing_list.packing_list_items.order(:created_at).last
        expect(created_item.note).to eq("メモ")
        expect(created_item.position).to eq(1)
      end
    end

    context "未ログインのとき" do
      it "ログイン画面へリダイレクトし、追加されない" do
        expect {
          post packing_list_packing_list_items_path(packing_list),
               params: { packing_list_item: { item_id: item.id } }
        }.not_to change(PackingListItem, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /packing_lists/:packing_list_id/packing_list_items/:id" do
    let!(:packing_list_item) { create(:packing_list_item, packing_list: packing_list, item: item, note: "旧メモ", position: 0) }

    it "項目の内容を更新してリストへリダイレクトする" do
      sign_in user, scope: :user

      patch packing_list_packing_list_item_path(packing_list, packing_list_item),
            params: { packing_list_item: { note: "新しいメモ", position: 2 } }

      expect(response).to redirect_to(packing_list_path(packing_list))
      packing_list_item.reload
      expect(packing_list_item.note).to eq("新しいメモ")
      expect(packing_list_item.position).to eq(2)
    end
  end

  describe "PATCH /packing_lists/:packing_list_id/packing_list_items/:id/toggle" do
    let!(:packing_list_item) { create(:packing_list_item, packing_list: packing_list, item: item, checked: false) }

    it "チェック状態をトグルしてリストへリダイレクトする" do
      sign_in user, scope: :user

      patch toggle_packing_list_packing_list_item_path(packing_list, packing_list_item)

      expect(response).to redirect_to(packing_list_path(packing_list))
      expect(packing_list_item.reload.checked).to be(true)
    end
  end

  describe "DELETE /packing_lists/:packing_list_id/packing_list_items/:id" do
    let!(:packing_list_item) { create(:packing_list_item, packing_list: packing_list, item: item) }

    it "項目を削除してリストへリダイレクトする" do
      sign_in user, scope: :user

      expect {
        delete packing_list_packing_list_item_path(packing_list, packing_list_item)
      }.to change { packing_list.packing_list_items.count }.by(-1)

      expect(response).to redirect_to(packing_list_path(packing_list))
    end
  end
end
