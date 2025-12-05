module Spotify
  class SearchTracks
    def self.call(query:, limit: 10, market: "JP")
      Spotify::Client.new.search_tracks(query: query, limit: limit, market: market)
    end
  end
end
