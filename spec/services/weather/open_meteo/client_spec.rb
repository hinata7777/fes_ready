require "rails_helper"
require "cgi"

RSpec.describe Weather::OpenMeteo::Client do
  let(:client) { described_class.new }
  let(:http) { instance_double(Net::HTTP) }
  let(:date) { Date.new(2025, 1, 1) }

  it "成功レスポンスをパースして返す" do
    body = {
      hourly: {
        time: [ "2025-01-01T08:00" ],
        temperature_2m: [ 20.0 ],
        weather_code: [ 0 ]
      }
    }.to_json

    ok_response = instance_double(Net::HTTPSuccess, body: body, code: "200")
    allow(ok_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(ok_response)

    json = client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)
    expect(json["hourly"]["temperature_2m"]).to eq([ 20.0 ])
  end

  it "失敗レスポンスなら例外を投げる" do
    failed_response = instance_double(Net::HTTPServerError, body: "err", code: "500")
    allow(failed_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(failed_response)

    expect {
      client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)
    }.to raise_error(/Open-Meteo forecast failed/)
  end

  it "デフォルトのtimezoneでクエリを組み立てる" do
    ok_response = instance_double(Net::HTTPSuccess, body: "{}", code: "200")
    allow(ok_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    captured_uri = nil
    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request) do |req|
      captured_uri = req.uri
      ok_response
    end

    client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)

    params = CGI.parse(captured_uri.query)
    expect(params["latitude"]).to eq([ "35.0" ])
    expect(params["longitude"]).to eq([ "139.0" ])
    expect(params["hourly"]).to eq([ "temperature_2m,weather_code" ])
    expect(params["start_date"]).to eq([ "2025-01-01" ])
    expect(params["end_date"]).to eq([ "2025-01-01" ])
    expect(params["timezone"]).to eq([ "Asia/Tokyo" ])
  end

  it "HTTPタイムアウト設定を渡してリクエストする" do
    ok_response = instance_double(Net::HTTPSuccess, body: "{}", code: "200")
    allow(ok_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(ok_response)

    client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)

    expect(Net::HTTP).to have_received(:start).with(
      anything,
      anything,
      hash_including(
        open_timeout: described_class::OPEN_TIMEOUT,
        read_timeout: described_class::READ_TIMEOUT
      )
    )
  end

  it "timezoneを上書きできる" do
    ok_response = instance_double(Net::HTTPSuccess, body: "{}", code: "200")
    allow(ok_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    captured_uri = nil
    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request) do |req|
      captured_uri = req.uri
      ok_response
    end

    client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date, timezone: "UTC")

    params = CGI.parse(captured_uri.query)
    expect(params["timezone"]).to eq([ "UTC" ])
  end

  it "成功レスポンスでもJSONが壊れていたら例外を投げる" do
    ok_response = instance_double(Net::HTTPSuccess, body: "{bad json", code: "200")
    allow(ok_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(ok_response)

    expect {
      client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)
    }.to raise_error(JSON::ParserError)
  end

  it "例外メッセージにステータスとボディが含まれる" do
    failed_response = instance_double(Net::HTTPServerError, body: "err", code: "500")
    allow(failed_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(failed_response)

    expect {
      client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: date)
    }.to raise_error("Open-Meteo forecast failed: 500 err")
  end
end
