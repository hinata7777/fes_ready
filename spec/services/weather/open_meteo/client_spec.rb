require "rails_helper"

RSpec.describe Weather::OpenMeteo::Client do
  let(:client) { described_class.new }
  let(:http) { instance_double(Net::HTTP) }

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

    json = client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: Date.new(2025, 1, 1))
    expect(json["hourly"]["temperature_2m"]).to eq([ 20.0 ])
  end

  it "失敗レスポンスなら例外を投げる" do
    failed_response = instance_double(Net::HTTPServerError, body: "err", code: "500")
    allow(failed_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

    allow(Net::HTTP).to receive(:start).and_return(http)
    allow(http).to receive(:request).and_return(failed_response)

    expect {
      client.hourly_forecast(latitude: 35.0, longitude: 139.0, date: Date.new(2025, 1, 1))
    }.to raise_error(/Open-Meteo forecast failed/)
  end
end
