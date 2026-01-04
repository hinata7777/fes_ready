require "rails_helper"

RSpec.describe "管理画面のセットリスト管理", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin, scope: :user }

  describe "POST /admin/setlists" do
    let(:stage_performance) { create(:stage_performance) }
    let(:song) { create(:song, artist: stage_performance.artist) }

    it "作成できる" do
      params = {
        setlist: {
          stage_performance_id: stage_performance.id,
          setlist_songs_attributes: {
            "0" => { song_id: song.id, position: 1, note: "" }
          }
        }
      }

      expect {
        post admin_setlists_path, params: params
      }.to change(Setlist, :count).by(1)

      expect(response).to redirect_to(admin_setlists_path)
    end
  end

  describe "PATCH /admin/setlists/:id" do
    let(:setlist) { create(:setlist) }
    let(:song) { create(:song, artist: setlist.stage_performance.artist) }

    it "編集できる" do
      params = {
        setlist: {
          setlist_songs_attributes: {
            "0" => { song_id: song.id, position: 1, note: "更新" }
          }
        }
      }

      patch admin_setlist_path(setlist), params: params

      expect(response).to redirect_to(admin_setlists_path)
    end
  end

  describe "DELETE /admin/setlists/:id" do
    let!(:setlist) { create(:setlist) }

    it "削除できる" do
      expect {
        delete admin_setlist_path(setlist)
      }.to change(Setlist, :count).by(-1)

      expect(response).to redirect_to(admin_setlists_path)
    end
  end
end
