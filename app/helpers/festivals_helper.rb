module FestivalsHelper
  def status_labels
    # enumのキーをUI表示用ラベルに変換する（I18nがなければhumanizeにフォールバック）
    Festival.status_filters.keys.index_with do |key|
      I18n.t("enums.festival.status_filter.#{key}", default: key.humanize)
    end
  end

  def festival_period_label(festival, with_weekday: false, fallback: nil)
    return fallback if festival.blank?

    formatter = with_weekday ? method(:format_date_with_weekday) : ->(date) { date&.strftime("%Y/%m/%d") }
    start_label = formatter.call(festival.start_date)
    end_label = formatter.call(festival.end_date)

    if start_label.present? && end_label.present?
      festival.end_date == festival.start_date ? start_label : "#{start_label} 〜 #{end_label}"
    elsif start_label.present?
      start_label
    elsif end_label.present?
      end_label
    else
      fallback
    end
  end

  def festival_location_label(festival, fallback: nil)
    return fallback if festival.blank?

    parts = []
    parts << "＠#{festival.prefecture}" if festival.prefecture.present?
    parts << festival.city if festival.city.present?
    parts << festival.venue_name if festival.venue_name.present?
    parts.any? ? parts.join(" ") : fallback
  end

  def festival_location_details(festival, fallback: "-")
    return { venue: fallback, area: nil } if festival.blank?

    venue = festival.venue_name.presence || fallback
    area_parts = [ festival.prefecture, festival.city ].compact_blank
    area = area_parts.any? ? area_parts.join(" / ") : nil

    { venue: venue, area: area }
  end

  def festival_official_url(festival)
    return if festival.blank?

    url = festival.official_url.to_s.strip
    url.presence
  end

  def festival_official_link(festival, class_name: "", fallback: "-")
    url = festival_official_url(festival)
    return fallback if url.blank?

    link_to url, url, class: class_name, target: "_blank", rel: "noopener"
  end

  def festival_coordinates_label(festival)
    return if festival.blank?
    return unless festival.latitude.present? && festival.longitude.present?

    "#{festival.latitude}, #{festival.longitude}"
  end

  def festival_coordinates_display(festival, class_name: "", fallback: "未設定")
    label = festival_coordinates_label(festival)
    return fallback if label.blank?

    content_tag(:span, label, class: class_name)
  end

  def festival_day_time_label(day, time_zone, attribute, fallback: "-")
    return fallback if day.blank?

    value = day.public_send(attribute)
    value ? value.in_time_zone(time_zone).strftime("%H:%M") : fallback
  end

  def festival_time_zone(festival)
    ActiveSupport::TimeZone[festival&.timezone] || Time.zone
  end

  def festival_timetable_status_badge(festival)
    return "" if festival.blank?

    if festival.timetable_published?
      tag.span class: "inline-flex items-center gap-2 rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700" do
        tag.span(class: "inline-block h-2 w-2 rounded-full bg-emerald-500") + "公開中"
      end
    else
      tag.span class: "inline-flex items-center gap-2 rounded-full bg-slate-200 px-3 py-1 text-xs font-semibold text-slate-600" do
        tag.span(class: "inline-block h-2 w-2 rounded-full bg-slate-400") + "非公開"
      end
    end
  end

  def festival_stage_badge_style(stage)
    return "" if stage.blank?

    hex = stage.color_hex
    text_color = stage_text_color(hex)
    "background-color: #{hex}; color: #{text_color};"
  end

  def festival_day_tabs(festival_days)
    day_lookup = Array(festival_days).index_by(&:id)
    tab_items = day_lookup.transform_values { |day| day.date.strftime("%-m/%-d") }
    { lookup: day_lookup, tabs: tab_items }
  end
end
