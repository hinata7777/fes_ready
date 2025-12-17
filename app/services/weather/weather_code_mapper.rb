module Weather
  class WeatherCodeMapper
    # Open-Meteo の weather_code を UI 表示用に「ざっくり分類」する。
    def kind_for(code)
      case code.to_i
      when 0
        :clear
      when 1..3
        :cloudy
      when 45, 48
        :fog
      when 51..57, 61..67, 80..82
        :rain
      when 71..77, 85..86
        :snow
      when 95..99
        :thunder
      else
        :unknown
      end
    end

    def icon_name_for(code)
      # `IconHelper#icon` が参照する SVG ファイル名（app/assets/images/icons/*.svg）を返す。
      case kind_for(code)
      when :clear
        "weather_sunny"
      when :cloudy
        "weather_cloudy"
      when :fog
        "weather_fog"
      when :rain
        "weather_rainy"
      when :snow
        "weather_snowy"
      when :thunder
        "weather_thunder"
      else
        "weather_cloudy"
      end
    end

    def tile_class_for(code)
      # Tailwind の背景色クラスを返す（文字色は View 側で必要に応じて調整）。
      case kind_for(code)
      when :clear
        "bg-orange-400"
      when :cloudy
        "bg-slate-500"
      when :fog
        "bg-slate-400"
      when :rain
        "bg-sky-500"
      when :snow
        "bg-indigo-200"
      when :thunder
        "bg-purple-600"
      else
        "bg-slate-500"
      end
    end
  end
end
