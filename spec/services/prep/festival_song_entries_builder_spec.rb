require "rails_helper"

RSpec.describe Prep::FestivalSongEntriesBuilder do
  describe "予習曲エントリの生成" do
    let(:festival) { create(:festival, start_date: Date.current, end_date: Date.current + 2) }
    let(:festival_day) { create(:festival_day, festival: festival) }
    let(:artist) { create(:artist, published: true) }

    it "draftの出演枠でも予習曲エントリを返す" do
      other_days = [
        create(:festival_day, festival: festival, date: festival.start_date + 1.day),
        create(:festival_day, festival: festival, date: festival.start_date + 2.days)
      ]
      stage_performances = [
        create(:stage_performance, festival_day: festival_day, artist: artist, status: :draft),
        create(:stage_performance, festival_day: other_days.first, artist: artist, status: :draft),
        create(:stage_performance, festival_day: other_days.last, artist: artist, status: :draft)
      ]
      song_one = create(:song, artist: artist, spotify_id: "0OdUWJ0sBjDrqHygGUXeC1")
      song_two = create(:song, artist: artist, spotify_id: "0OdUWJ0sBjDrqHygGUXeC2")

      stage_performances.each do |stage_performance|
        setlist = create(:setlist, stage_performance: stage_performance)
        create(:setlist_song, setlist: setlist, song: song_one, position: 1)
        create(:setlist_song, setlist: setlist, song: song_two, position: 2)
      end

      result = described_class.build(festival: festival, selected_day: festival_day)

      expect(result.size).to eq(2)
      expect(result.map { |entry| entry[:artist] }.uniq).to eq([ artist ])
      expect(result.map { |entry| entry[:song] }).to include(song_one, song_two)
    end
  end
end
