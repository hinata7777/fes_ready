require "rails_helper"

RSpec.describe "マイタイムテーブルの編集", type: :system do
  before { driven_by :rack_test }

  it "ログインして出演枠を選択し保存できる" do
    user = create(:user, password: "password")
    festival = create(:festival)
    festival_day = create(:festival_day, festival: festival, date: festival.start_date)
    stage = create(:stage, festival: festival)
    artist = create(:artist, name: "テストアーティスト")
    create(
      :stage_performance,
      :scheduled,
      festival_day: festival_day,
      stage: stage,
      artist: artist,
      starts_at: festival_day.date.to_time.change(hour: 12),
      ends_at: festival_day.date.to_time.change(hour: 13)
    )

    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログインする"

    visit edit_festival_my_timetable_path(festival, date: festival_day.date.to_s)
    expect(page).to have_content("マイタイムテーブル編集")

    find("label", text: artist.name).click
    click_button "保存する"

    expect(page).to have_content("マイタイムテーブルを保存しました。")
    expect(page).to have_content(artist.name)
    expect(page).not_to have_content("この日に選択した出演がまだありません。")
  end
end
