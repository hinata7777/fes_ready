require "rails_helper"

RSpec.describe Weather::WeatherCodeMapper do
  describe "#kind_for / #icon_name_for / #tile_class_for" do
    let(:mapper) { described_class.new }

    it "コードを種別とアイコン・色にマッピングできる" do
      expect(mapper.kind_for(0)).to eq(:clear)
      expect(mapper.icon_name_for(0)).to eq("weather_sunny")
      expect(mapper.tile_class_for(0)).to eq("bg-orange-400")

      expect(mapper.kind_for(61)).to eq(:rain)
      expect(mapper.icon_name_for(61)).to eq("weather_rainy")
      expect(mapper.tile_class_for(61)).to eq("bg-sky-500")

      expect(mapper.kind_for(99)).to eq(:thunder)
      expect(mapper.icon_name_for(99)).to eq("weather_thunder")
      expect(mapper.tile_class_for(99)).to eq("bg-purple-600")

      expect(mapper.kind_for(999)).to eq(:unknown)
      expect(mapper.icon_name_for(999)).to eq("weather_cloudy")
      expect(mapper.tile_class_for(999)).to eq("bg-slate-500")
    end
  end
end
