module Prep
  class FestivalSongEntriesBuilder
    def self.build(festival:, selected_day:)
      new(festival: festival, selected_day: selected_day).build
    end

    def initialize(festival:, selected_day:)
      @festival = festival
      @selected_day = selected_day
    end

    def build
      performing_artists = Artist
                             .joins(stage_performances: :festival_day)
                             .where(stage_performances: { status: StagePerformance.statuses[:scheduled] },
                                    festival_days: { id: @selected_day.id, festival_id: @festival.id })
                             .merge(Artist.published)
                             .distinct
                             .order(:name)

      entries = performing_artists.flat_map do |artist|
        setlist_scope = Setlist
                         .joins(:stage_performance)
                         .where(stage_performances: { artist_id: artist.id })

        ranking = Prep::SongRankingBuilder.build(artist: artist, setlist_scope: setlist_scope)
        next if ranking.entries.empty?

        spotify_pick = ranking.entries
                               .select { |entry| entry[:song].spotify_id.present? }
                               .first(2)

        next if spotify_pick.empty?

        spotify_pick.map { |entry| entry.merge(artist: artist) }
      end.compact

      entries
    end

    private

    attr_reader :festival, :selected_day
  end
end
