require "rails_helper"

RSpec.describe "持ち物リストのリクエスト", type: :request do
  describe "GET /packing_lists" do
    it "未ログインでも一覧を表示できる" do
      get packing_lists_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /packing_lists/:id" do
    let!(:template_list) { create(:template_packing_list, title: "テンプレート") }

    it "未ログインならログイン画面へリダイレクトする" do
      get packing_list_path(template_list)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "他人の通常リストにはログイン画面へリダイレクトする" do
      other_list = create(:packing_list, user: create(:user))

      get packing_list_path(other_list)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "自分のリストならログインして閲覧できる" do
      user = create(:user)
      own_list = create(:packing_list, user: user)

      sign_in user, scope: :user
      get packing_list_path(own_list)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /packing_lists/:id/edit" do
    it "未ログインならログイン画面へリダイレクトする" do
      list = create(:packing_list, user: create(:user))

      get edit_packing_list_path(list)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "他人のリストは404を返す" do
      owner = create(:user)
      other = create(:user)
      list = create(:packing_list, user: owner)

      sign_in other, scope: :user

      get edit_packing_list_path(list)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /packing_lists/new" do
    it "未ログインならログイン画面へリダイレクトする" do
      get new_packing_list_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

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
      before { sign_in user, scope: :user }

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

    context "バリデーションエラーのとき" do
      it "422でnewを再表示する" do
        sign_in user, scope: :user

        expect {
          post packing_lists_path, params: { packing_list: { title: "" } }
        }.not_to change(PackingList, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /packing_lists/:id" do
    it "未ログインならログイン画面へリダイレクトし、更新されない" do
      list = create(:packing_list, user: create(:user), title: "旧タイトル")

      patch packing_list_path(list), params: { packing_list: { title: "更新タイトル" } }

      expect(response).to redirect_to(new_user_session_path)
      expect(list.reload.title).to eq("旧タイトル")
    end

    it "他人のリストは404を返す" do
      owner = create(:user)
      other = create(:user)
      list = create(:packing_list, user: owner, title: "旧タイトル")

      sign_in other, scope: :user

      patch packing_list_path(list), params: { packing_list: { title: "更新タイトル" } }
      expect(response).to have_http_status(:not_found)

      expect(list.reload.title).to eq("旧タイトル")
    end

    it "バリデーションエラーなら422を返し、タイトルは更新されない" do
      user = create(:user)
      list = create(:packing_list, user: user, title: "旧タイトル")

      sign_in user, scope: :user

      patch packing_list_path(list), params: { packing_list: { title: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(list.reload.title).to eq("旧タイトル")
    end

    it "自分のリストなら更新できる" do
      user = create(:user)
      list = create(:packing_list, user: user, title: "旧タイトル")

      sign_in user, scope: :user

      patch packing_list_path(list), params: { packing_list: { title: "更新タイトル" } }

      expect(response).to have_http_status(:found)
      expect(list.reload.title).to eq("更新タイトル")
    end
  end

  describe "DELETE /packing_lists/:id" do
    it "未ログインならログイン画面へリダイレクトし、削除されない" do
      list = create(:packing_list, user: create(:user))

      expect {
        delete packing_list_path(list)
      }.not_to change(PackingList, :count)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "他人のリストは404を返し、削除しない" do
      owner = create(:user)
      other = create(:user)
      list = create(:packing_list, user: owner)

      sign_in other, scope: :user

      delete packing_list_path(list)
      expect(response).to have_http_status(:not_found)

      expect(PackingList.exists?(list.id)).to be(true)
    end

    it "自分のリストなら削除できる" do
      user = create(:user)
      list = create(:packing_list, user: user)

      sign_in user, scope: :user

      expect {
        delete packing_list_path(list)
      }.to change(PackingList, :count).by(-1)

      expect(response).to redirect_to(packing_lists_path)
    end
  end
end
