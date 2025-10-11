module Spotify
  class SearchArtists
    def self.call(query:, limit: 10, market: "JP")
      Spotify::Client.new.search_artists(query: query, limit: limit, market: market)
    end
  end
end
