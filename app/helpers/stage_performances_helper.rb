module StagePerformancesHelper
  def stage_performance_time_zone(stage_performance)
    festival = stage_performance&.festival_day&.festival
    ActiveSupport::TimeZone[festival&.timezone] || Time.zone
  end

  def stage_performance_time_zone_label(stage_performance, time_zone: nil)
    time_zone ||= stage_performance_time_zone(stage_performance)
    festival = stage_performance&.festival_day&.festival
    festival&.timezone || time_zone.tzinfo.name
  end

  def stage_performance_starts_at_label(stage_performance, time_zone:, fallback: "-")
    starts_at = stage_performance&.starts_at
    starts_at ? starts_at.in_time_zone(time_zone).strftime("%Y/%m/%d %H:%M") : fallback
  end

  def stage_performance_ends_at_label(stage_performance, time_zone:, fallback: "-")
    ends_at = stage_performance&.ends_at
    ends_at ? ends_at.in_time_zone(time_zone).strftime("%Y/%m/%d %H:%M") : fallback
  end

  def stage_performance_duration_label(stage_performance, time_zone:, fallback: "-")
    starts_at = stage_performance&.starts_at
    ends_at   = stage_performance&.ends_at
    return fallback if starts_at.blank? || ends_at.blank?

    duration = ((ends_at.in_time_zone(time_zone) - starts_at.in_time_zone(time_zone)) / 60.0).round
    "#{duration.to_i} 分"
  end

  def stage_performance_time_range_label(stage_performance, fallback: "-")
    return fallback if stage_performance.blank?

    starts_at = stage_performance.starts_at
    ends_at = stage_performance.ends_at
    return fallback if starts_at.blank? || ends_at.blank?

    time_zone = stage_performance_time_zone(stage_performance)
    start_label = starts_at.in_time_zone(time_zone).strftime("%H:%M")
    end_label = ends_at.in_time_zone(time_zone).strftime("%H:%M")
    "#{start_label}–#{end_label}"
  end

  def stage_performance_status_badges(stage_performance)
    return "" if stage_performance.blank?

    badges = []
    if stage_performance.scheduled?
      badges << content_tag(:span, "scheduled", class: "inline-flex items-center rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-semibold text-emerald-700")
    else
      badges << content_tag(:span, "draft", class: "inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold text-slate-700")
    end
    if stage_performance.canceled?
      badges << content_tag(:span, "canceled", class: "inline-flex items-center rounded-full bg-rose-50 px-2.5 py-0.5 text-[11px] font-semibold text-rose-700")
    end

    safe_join(badges, " ")
  end

  def stage_performance_festival_day_options(festival_days)
    [ [ "すべて", nil ] ] + festival_days.map do |day|
      [ "#{day.festival.name} / #{day.date.strftime('%Y/%m/%d')}", day.id ]
    end
  end

  def stage_performance_artist_options(artists)
    [ [ "すべて", nil ] ] + artists.map { |artist| [ artist.name, artist.id ] }
  end

  def stage_color_badge(stage)
    return if stage.blank? || stage.color_key.blank?

    content_tag(:span,
                class: "ml-2 inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold",
                style: "background-color: #{stage.color_hex}; color: #{stage_text_color(stage.color_hex)};") do
      content_tag(:span, stage.color_key)
    end
  end
end
