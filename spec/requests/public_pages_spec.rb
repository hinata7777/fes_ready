require "rails_helper"

RSpec.describe "公開ページのリクエスト", type: :request do
  describe "トップと基本ページ" do
    it "トップページが200を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "利用規約ページが200を返す" do
      get terms_path
      expect(response).to have_http_status(:ok)
    end

    it "プライバシーポリシーページが200を返す" do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end

    it "運営者情報ページが200を返す" do
      get operator_path
      expect(response).to have_http_status(:ok)
    end

    it "ガイドページが200を返す" do
      get guide_path
      expect(response).to have_http_status(:ok)
    end

    it "ガイドページではガイドボタンを表示しない" do
      get guide_path
      expect(response.body).not_to include("ガイドを見る")
    end
  end

  describe "フェス・アーティストの一覧/詳細" do
    let!(:festival) { create(:festival) }
    let!(:festival_day) { create(:festival_day, festival: festival) }
    let!(:artist) { create(:artist) }

    it "フェス一覧が200を返す" do
      get festivals_path
      expect(response).to have_http_status(:ok)
    end

    it "フェス詳細が200を返す" do
      get festival_path(festival)
      expect(response).to have_http_status(:ok)
    end

    it "アーティスト一覧が200を返す" do
      get artists_path
      expect(response).to have_http_status(:ok)
    end

    it "アーティスト詳細が200を返す" do
      get artist_path(artist)
      expect(response).to have_http_status(:ok)
    end

    it "フェス一覧でキーワード検索が反映される" do
      matching = create(:festival, name: "Rock Summer Fest")
      other = create(:festival, name: "Jazz Night")

      get festivals_path, params: { q: { name_i_cont: "Rock" } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching.name)
      expect(response.body).not_to include(other.name)
    end
  end

  describe "タイムテーブルの一覧/詳細" do
    let!(:timetable_festival) { create(:festival, timetable_published: true) }
    let!(:timetable_day) { create(:festival_day, festival: timetable_festival, date: timetable_festival.start_date) }
    let!(:stage) { create(:stage, festival: timetable_festival) }
    let!(:performance) do
      create(:stage_performance, :scheduled, festival_day: timetable_day, stage: stage, artist: create(:artist))
    end

    it "タイムテーブル一覧が200を返す" do
      get timetables_path
      expect(response).to have_http_status(:ok)
    end

    it "タイムテーブル詳細が200を返す" do
      get timetable_path(timetable_festival, date: timetable_day.date.to_s)
      expect(response).to have_http_status(:ok)
    end

    it "未公開タイムテーブルなら404を返す" do
      unpublished = create(:festival, timetable_published: false)
      create(:festival_day, festival: unpublished, date: unpublished.start_date)

      get timetable_path(unpublished, date: unpublished.start_date.to_s)
      expect(response).to have_http_status(:not_found)
    end

    it "不正な日付パラメータなら404を返す" do
      get timetable_path(timetable_festival, date: "invalid-date")
      expect(response).to have_http_status(:not_found)
    end

    it "タイムテーブル一覧でキーワード検索が反映される" do
      matching = create(:festival, name: "Sky Rock Day", timetable_published: true)
      other = create(:festival, name: "Blue Jazz Day", timetable_published: true)

      get timetables_path, params: { q: { name_i_cont: "Rock" } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching.name)
      expect(response.body).not_to include(other.name)
    end
  end

  describe "セットリスト詳細" do
    let!(:festival) { create(:festival, timetable_published: true) }
    let!(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }
    let!(:stage) { create(:stage, festival: festival) }
    let!(:performance) do
      create(:stage_performance, :scheduled, festival_day: festival_day, stage: stage, artist: create(:artist))
    end
    let!(:setlist) { create(:setlist, stage_performance: performance) }

    it "セットリスト詳細が200を返す" do
      get setlist_path(setlist)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "準備ページとプレップ用一覧/詳細" do
    let!(:prep_festival) { create(:festival, timetable_published: true) }
    let!(:prep_festival_day) { create(:festival_day, festival: prep_festival, date: prep_festival.start_date) }
    let!(:prep_artist) { create(:artist) }

    it "準備トップが200を返す" do
      get prep_path
      expect(response).to have_http_status(:ok)
    end

    it "プレップ用フェス一覧が200を返す" do
      get prep_festivals_path
      expect(response).to have_http_status(:ok)
    end

    it "プレップ用フェス詳細が200を返す" do
      get prep_festival_path(prep_festival, date: prep_festival_day.date.to_s)
      expect(response).to have_http_status(:ok)
    end

    it "プレップ用フェス詳細で不正な日付なら404を返す" do
      get prep_festival_path(prep_festival, date: "invalid-date")
      expect(response).to have_http_status(:not_found)
    end

    it "プレップ用アーティスト一覧が200を返す" do
      get prep_artists_path
      expect(response).to have_http_status(:ok)
    end

    it "プレップ用アーティスト詳細が200を返す" do
      get prep_artist_path(prep_artist)
      expect(response).to have_http_status(:ok)
    end
  end
end
