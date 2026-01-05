require "rails_helper"

RSpec.describe "管理画面の持ち物テンプレート管理", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin, scope: :user }

  describe "POST /admin/packing_lists" do
    let(:festival_day) { create(:festival_day) }
    let(:item) { create(:item) }

    it "テンプレートを作成できる" do
      params = {
        packing_list: {
          title: "テンプレ",
          festival_day_id: festival_day.id,
          packing_list_items_attributes: {
            "0" => { item_id: item.id, note: "必須", position: 0 }
          }
        }
      }

      expect {
        post admin_packing_lists_path, params: params
      }.to change(PackingList, :count).by(1)
         .and change(PackingListItem, :count).by(1)

      expect(response).to redirect_to(admin_packing_lists_path)
    end
  end

  describe "PATCH /admin/packing_lists/:id" do
    let(:packing_list) { create(:template_packing_list) }

    it "テンプレートを更新できる" do
      params = {
        packing_list: {
          title: "更新後テンプレ"
        }
      }

      patch admin_packing_list_path(packing_list), params: params

      expect(response).to redirect_to(admin_packing_lists_path)
      expect(packing_list.reload.title).to eq("更新後テンプレ")
    end
  end

  describe "DELETE /admin/packing_lists/:id" do
    let!(:packing_list) { create(:template_packing_list) }

    it "テンプレートを削除できる" do
      expect {
        delete admin_packing_list_path(packing_list)
      }.to change(PackingList, :count).by(-1)

      expect(response).to redirect_to(admin_packing_lists_path)
    end
  end
end
