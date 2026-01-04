require "rails_helper"

RSpec.describe "管理画面の曲管理", type: :request do
  let(:admin) { create(:user, role: :admin) }

  before { sign_in admin, scope: :user }

  describe "POST /admin/songs" do
    let(:artist) { create(:artist) }

    it "有効な行があれば曲を作成して一覧へ戻る" do
      params = {
        bulk: {
          entries: [
            {
              name: "テスト曲",
              spotify_id: "",
              artist_id: artist.id,
              _destroy: "0"
            }
          ]
        }
      }

      expect {
        post admin_songs_path, params: params
      }.to change(Song, :count).by(1)

      expect(response).to redirect_to(admin_songs_path)
    end

    it "有効な行がなければ作成せず422を返す" do
      params = {
        bulk: {
          entries: [
            {
              name: "",
              spotify_id: "",
              artist_id: "",
              _destroy: "0"
            }
          ]
        }
      }

      expect {
        post admin_songs_path, params: params
      }.not_to change(Song, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /admin/songs/:id" do
    let(:artist) { create(:artist) }
    let(:song) { create(:song, artist: artist, name: "旧曲名") }

    it "編集内容を更新できる" do
      params = { song: { name: "新曲名" } }

      patch admin_song_path(song), params: params

      expect(response).to redirect_to(admin_songs_path)
      expect(song.reload.name).to eq("新曲名")
    end
  end

  describe "DELETE /admin/songs/:id" do
    let(:artist) { create(:artist) }
    let!(:song) { create(:song, artist: artist) }

    it "曲を削除できる" do
      expect {
        delete admin_song_path(song)
      }.to change(Song, :count).by(-1)

      expect(response).to redirect_to(admin_songs_path)
    end
  end
end
