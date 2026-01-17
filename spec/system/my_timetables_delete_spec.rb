require "rails_helper"

RSpec.describe "マイタイムテーブルの削除", type: :system do
  before { driven_by :rack_test }

  it "マイタイムテーブルを削除できる" do
    user = create(:user, password: "password")
    festival = create(:festival)
    festival_day = create(:festival_day, festival: festival, date: festival.start_date)
    stage = create(:stage, festival: festival)
    artist = create(:artist, name: "テストアーティスト")
    performance = create(
      :stage_performance,
      :scheduled,
      festival_day: festival_day,
      stage: stage,
      artist: artist,
      starts_at: festival_day.date.to_time.change(hour: 12),
      ends_at: festival_day.date.to_time.change(hour: 13)
    )
    create(:user_timetable_entry, user: user, stage_performance: performance)

    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログインする"

    visit festival_my_timetable_path(festival, date: festival_day.date.to_s, user_id: user.uuid)
    expect(page).to have_content("マイタイムテーブル")

    click_button "削除する"

    expect(page).to have_content("マイタイムテーブルを削除しました。")
    expect(page).to have_content("まだ保存したマイタイムテーブルがありません。")
  end
end
