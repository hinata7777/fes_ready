require "net/http"
require "uri"
require "json"
require "base64"

module Spotify
  class Client
    TOKEN_URL  = "https://accounts.spotify.com/api/token"
    SEARCH_URL = "https://api.spotify.com/v1/search"

    def initialize
      @client_id     = ENV["SPOTIFY_CLIENT_ID"]     || Rails.application.credentials.dig(:spotify, :client_id)
      @client_secret = ENV["SPOTIFY_CLIENT_SECRET"] || Rails.application.credentials.dig(:spotify, :client_secret)
      raise "Spotify credentials missing" if @client_id.blank? || @client_secret.blank?
    end

    def search_artists(query:, limit: 10, market: "JP")
      return [] if query.to_s.strip.empty?
      uri = URI(SEARCH_URL)
      uri.query = URI.encode_www_form(q: query, type: "artist", limit: limit, market: market)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{access_token}"

      res = http(uri).request(req)
      raise "Spotify search failed: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      json = JSON.parse(res.body)
      (json.dig("artists", "items") || []).map do |a|
        {
          id: a["id"],
          name: a["name"],
          image_url: (a["images"]&.first && a["images"].first["url"]),
          genres: a["genres"],
          popularity: a["popularity"]
        }
      end
    end

    def search_tracks(query:, limit: 10, market: "JP")
      return [] if query.to_s.strip.empty?
      uri = URI(SEARCH_URL)
      uri.query = URI.encode_www_form(q: query, type: "track", limit: limit, market: market)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{access_token}"

      res = http(uri).request(req)
      raise "Spotify search failed: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      json = JSON.parse(res.body)
      (json.dig("tracks", "items") || []).map do |t|
        {
          id: t["id"],
          name: t["name"],
          artists: (t["artists"] || []).map { |a| { id: a["id"], name: a["name"] } },
          album_name: t.dig("album", "name"),
          image_url: (t.dig("album", "images")&.first && t.dig("album", "images")&.first["url"]),
          preview_url: t["preview_url"]
        }
      end
    end

    private

    def http(uri) = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https")

    def access_token
      Rails.cache.fetch("spotify_access_token", expires_in: 50.minutes) { fetch_access_token }
    end

    def fetch_access_token
      uri = URI(TOKEN_URL)
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Basic #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}"
      req.set_form_data(grant_type: "client_credentials")

      res = http(uri).request(req)
      raise "Spotify token failed: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body).fetch("access_token")
    end
  end
end
