require "rails_helper"

RSpec.describe "フェスのタイムテーブル閲覧", type: :system do
  before { driven_by :rack_test }

  it "フェス一覧から詳細を開きタイムテーブルを閲覧できる" do
    festival = create(:festival, timetable_published: true)
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

    visit festivals_path
    click_link festival.name

    expect(page).to have_content(festival.name)
    click_link "タイムテーブルへ"

    expect(page).to have_content("タイムテーブル")
    expect(page).to have_content(artist.name)
  end
end
