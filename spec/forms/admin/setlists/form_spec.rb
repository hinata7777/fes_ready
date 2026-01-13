require "rails_helper"

RSpec.describe Admin::Setlists::Form do
  describe "#build_rows" do
    it "ポジション1〜20の行を補完する" do
      setlist = build(:setlist)
      form = described_class.new(setlist: setlist)

      form.build_rows

      positions = setlist.setlist_songs.map(&:position)
      expect(positions).to include(1, 20)
      expect(positions.uniq.size).to eq(positions.size)
    end
  end

  describe "#save" do
    it "曲未選択の行は保存対象から外れる" do
      stage_performance = create(:stage_performance, :scheduled)
      setlist = Setlist.new(stage_performance: stage_performance)

      params = ActionController::Parameters.new(
        setlist: {
          stage_performance_id: stage_performance.id,
          setlist_songs_attributes: {
            "0" => { position: 1, song_id: "" },
            "1" => { position: 2, song_id: create(:song, artist: stage_performance.artist).id }
          }
        }
      )

      form = described_class.new(setlist: setlist, params: params)

      expect(form.save).to be(true)
      expect(setlist.setlist_songs.map(&:position)).to eq([ 2 ])
    end
  end
end
