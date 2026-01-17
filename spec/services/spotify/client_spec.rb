require "rails_helper"

RSpec.describe Spotify::Client do
  before do
    stub_const("ENV", ENV.to_hash.merge("SPOTIFY_CLIENT_ID" => "id", "SPOTIFY_CLIENT_SECRET" => "secret"))
  end

  let(:http) { instance_double(Net::HTTP) }
  let(:client) { described_class.new }

  describe "#search_artists" do
    it "トークン取得と検索が成功したら結果をパースして返す" do
      token_response = instance_double(Net::HTTPSuccess, body: { access_token: "tok" }.to_json, code: "200")
      allow(token_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      search_body = {
        artists: { items: [ { "id" => "1", "name" => "Artist", "images" => [ { "url" => "img" } ], "genres" => [ "rock" ], "popularity" => 50 } ] }
      }.to_json
      search_response = instance_double(Net::HTTPSuccess, body: search_body, code: "200")
      allow(search_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      allow(Net::HTTP).to receive(:start).and_return(http)
      allow(http).to receive(:request).and_return(token_response, search_response)

      result = client.search_artists(query: "rock")

      expect(result.first[:id]).to eq("1")
      expect(result.first[:name]).to eq("Artist")
      expect(result.first[:image_url]).to eq("img")
    end

    it "検索が失敗したら例外を投げる" do
      token_response = instance_double(Net::HTTPSuccess, body: { access_token: "tok" }.to_json, code: "200")
      allow(token_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      failed_response = instance_double(Net::HTTPServerError, body: "err", code: "500")
      allow(failed_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

      allow(Net::HTTP).to receive(:start).and_return(http)
      allow(http).to receive(:request).and_return(token_response, failed_response)

      expect {
        client.search_artists(query: "rock")
      }.to raise_error(/Spotify search failed/)
    end

    it "HTTPタイムアウト設定を渡してリクエストする" do
      token_response = instance_double(Net::HTTPSuccess, body: { access_token: "tok" }.to_json, code: "200")
      allow(token_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      search_body = { artists: { items: [] } }.to_json
      search_response = instance_double(Net::HTTPSuccess, body: search_body, code: "200")
      allow(search_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      allow(Net::HTTP).to receive(:start).and_return(http)
      allow(http).to receive(:request).and_return(token_response, search_response)

      client.search_artists(query: "rock")

      expect(Net::HTTP).to have_received(:start).with(
        anything,
        anything,
        hash_including(
          open_timeout: described_class::OPEN_TIMEOUT,
          read_timeout: described_class::READ_TIMEOUT
        )
      ).twice
    end
  end
end
