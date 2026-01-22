require "rails_helper"

RSpec.describe Weather::FestivalDayForecast do
  let(:festival) {
    create(:festival,
           start_date: Date.new(2025, 1, 1),
           end_date: Date.new(2025, 1, 2),
           latitude: 35.0,
           longitude: 139.0,
           venue_name: "会場名")
  }
  let(:festival_day) { create(:festival_day, festival: festival, date: festival.start_date) }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  def dummy_json(date)
    times = []
    temps = []
    codes = []

    Weather::FestivalDayForecast::DISPLAY_HOURS.each_with_index do |hour, idx|
      times << "#{date.iso8601}T#{format('%02d', hour)}:00"
      temps << (20 + idx)
      codes << (idx.even? ? 0 : 61) # 交互に晴れ/雨
    end

    {
      "hourly" => {
        "time" => times,
        "temperature_2m" => temps,
        "weather_code" => codes
      }
    }
  end

  it "緯度経度がない場合はnilを返す" do
    no_location_day = create(:festival_day, festival: create(:festival, latitude: nil, longitude: nil))
    client = instance_double(Weather::OpenMeteo::Client)
    mapper = instance_double(Weather::WeatherCodeMapper)

    result = described_class.new(festival_day: no_location_day, client: client, mapper: mapper, cache: cache).call
    expect(result).to be_nil
  end

  it "キャッシュ経由で予報を取得し、表示用の構造体を返す" do
    client = instance_double(Weather::OpenMeteo::Client)
    mapper = instance_double(Weather::WeatherCodeMapper, icon_name_for: "icon", tile_class_for: "tile")
    allow(client).to receive(:hourly_forecast).and_return(dummy_json(festival_day.date))

    result = described_class.new(festival_day: festival_day, client: client, mapper: mapper, cache: cache).call

    expect(client).to have_received(:hourly_forecast).once
    expect(result.date).to eq(festival_day.date)
    expect(result.timezone).to eq(Weather::FestivalDayForecast::TIMEZONE)
    expect(result.venue_name).to eq("会場名")
    expect(result.hour_labels).to eq(Weather::FestivalDayForecast::DISPLAY_HOURS)
    expect(result.slots.size).to eq(Weather::FestivalDayForecast::DISPLAY_HOURS.size)
    expect(result.slots.first.temperature_label).to include("℃")
    expect(result.slots.map(&:icon_name)).to all(eq("icon"))
    expect(result.slots.map(&:tile_class)).to all(eq("tile"))
  end

  it "APIエラー時は例外を握りつぶしてnilを返す" do
    client = instance_double(Weather::OpenMeteo::Client)
    mapper = instance_double(Weather::WeatherCodeMapper)
    allow(client).to receive(:hourly_forecast).and_raise(StandardError.new("api error"))

    result = described_class.new(festival_day: festival_day, client: client, mapper: mapper, cache: cache).call
    expect(result).to be_nil
  end

  it "同じキーではキャッシュが効き、クライアント呼び出しは1回だけ" do
    client = instance_double(Weather::OpenMeteo::Client)
    mapper = instance_double(Weather::WeatherCodeMapper, icon_name_for: "icon", tile_class_for: "tile")
    allow(client).to receive(:hourly_forecast).and_return(dummy_json(festival_day.date))

    service = described_class.new(festival_day: festival_day, client: client, mapper: mapper, cache: cache)
    2.times { service.call }

    expect(client).to have_received(:hourly_forecast).once
  end

  it "festival_dayやfestivalがnilならnilを返す" do
    client = instance_double(Weather::OpenMeteo::Client)
    mapper = instance_double(Weather::WeatherCodeMapper)

    expect(described_class.new(festival_day: nil, client: client, mapper: mapper, cache: cache).call).to be_nil
    orphan_day = FestivalDay.new(festival: nil, date: festival_day.date)
    expect(described_class.new(festival_day: orphan_day, client: client, mapper: mapper, cache: cache).call).to be_nil
  end
end
