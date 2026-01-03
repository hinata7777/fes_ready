module Prep
  class SongRankingBuilder
    Result = Struct.new(:entries, :setlists_count, keyword_init: true)

    def self.build(artist:, setlist_scope:, min_setlists: 3, limit: 5)
      new(
        artist: artist,
        setlist_scope: setlist_scope,
        min_setlists: min_setlists,
        limit: limit
      ).build
    end

    def initialize(artist:, setlist_scope:, min_setlists:, limit:)
      @artist = artist
      @setlist_scope = setlist_scope
      @min_setlists = min_setlists
      @limit = limit
    end

    def build
      setlists_count = setlist_scope.count
      return Result.new(entries: [], setlists_count: setlists_count) if setlists_count < min_setlists

      ranked_songs = Song
                      .joins(setlist_songs: :setlist)
                      .where(artist_id: artist.id, setlists: { id: setlist_scope.select(:id) })
                      .select("songs.*", "COUNT(DISTINCT setlist_songs.setlist_id) AS appearances_count")
                      .group("songs.id")
                      .order("appearances_count DESC", "songs.name ASC")
                      .limit(limit)

      entries = ranked_songs.map do |song|
        count = song.read_attribute(:appearances_count).to_i
        rate  = ((count.to_f / setlists_count) * 100).round(1)
        { song: song, count: count, rate: rate }
      end

      Result.new(entries: entries, setlists_count: setlists_count)
    end

    private

    attr_reader :artist, :setlist_scope, :min_setlists, :limit
  end
end
