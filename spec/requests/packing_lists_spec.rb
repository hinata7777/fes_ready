require "rails_helper"

RSpec.describe "持ち物リストのリクエスト", type: :request do
  describe "POST /packing_lists" do
    let(:user) { create(:user) }
    let(:params) do
      {
        packing_list: {
          title: "遠征用リスト",
          packing_list_items_attributes: {
            "0" => {
              position: 0,
              note: "雨用の装備",
              item_attributes: { name: "タオル" }
            }
          }
        }
      }
    end

    context "ログイン済みのとき" do
      before { sign_in user }

      it "新しい持ち物リストとアイテムを作成して詳細ページへリダイレクトする" do
        expect {
          post packing_lists_path, params: params
        }.to change(PackingList, :count).by(1)
          .and change(Item, :count).by(1)

        created_list = PackingList.order(:created_at).last
        expect(response).to redirect_to(packing_list_path(created_list))
        expect(created_list.user).to eq(user)
        expect(created_list.template).to be(false)

        created_item = created_list.packing_list_items.first.item
        expect(created_item.user).to eq(user)
        expect(created_item.template).to be(false)
        expect(created_item.name).to eq("タオル")
      end
    end

    context "未ログインのとき" do
      it "ログイン画面へリダイレクトし、作成されない" do
        expect {
          post packing_lists_path, params: params
        }.not_to change(PackingList, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /packing_lists/:id/duplicate_from_template" do
    let(:user) { create(:user) }
    let!(:template_item) { create(:template_item, name: "レインコート") }
    let!(:template_list) do
      create(:template_packing_list, title: "夏フェス基本セット").tap do |list|
        create(:packing_list_item, packing_list: list, item: template_item, position: 1, note: "必須")
      end
    end

    before { sign_in user }

    it "テンプレートからリストとアイテムを複製して詳細ページへリダイレクトする" do
      expect {
        post duplicate_from_template_packing_list_path(template_list)
      }.to change { user.packing_lists.count }.by(1)
        .and change(PackingListItem, :count).by(1)

      new_list = user.packing_lists.order(:created_at).last
      expect(response).to redirect_to(packing_list_path(new_list))
      expect(new_list.title).to eq(template_list.title)
      expect(new_list.template).to be(false)

      duplicated_item = new_list.packing_list_items.first
      expect(duplicated_item.item).to eq(template_item)
      expect(duplicated_item.position).to eq(1)
      expect(duplicated_item.note).to eq("必須")
    end

    it "テンプレートでない場合は複製せず一覧へリダイレクトする" do
      owned_list = create(:packing_list, user: user, template: false)
      create(:packing_list_item, packing_list: owned_list, item: create(:item, user: user))

      expect {
        post duplicate_from_template_packing_list_path(owned_list)
      }.not_to change(PackingList, :count)

      expect(response).to redirect_to(packing_lists_path)
    end
  end
end
