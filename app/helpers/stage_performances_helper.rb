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

  def stage_performance_header_status_badge(stage_performance)
    return "" if stage_performance.blank?

    if stage_performance.scheduled?
      content_tag(:span,
                  "scheduled",
                  class: "inline-flex items-center rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-emerald-700")
    else
      content_tag(:span,
                  "draft",
                  class: "inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-slate-700")
    end
  end

  def stage_performance_festival_cell(stage_performance)
    festival = stage_performance&.festival_day&.festival
    return "-" if festival.blank?

    safe_join([
      link_to(festival.name, admin_festival_path(festival), class: "text-indigo-600 hover:underline"),
      content_tag(:div, "ID: #{content_tag(:span, festival.id, class: "font-mono")}".html_safe, class: "text-xs text-slate-500")
    ])
  end

  def stage_performance_day_label(stage_performance, fallback: "-")
    day = stage_performance&.festival_day
    day&.date.present? ? day.date.strftime("%Y/%m/%d (%a)") : fallback
  end

  def stage_performance_artist_cell(stage_performance)
    artist = stage_performance&.artist
    return "-" if artist.blank?

    link_to(artist.name, admin_artist_path(artist), class: "text-slate-900 hover:underline")
  end

  def stage_performance_stage_cell(stage_performance)
    stage = stage_performance&.stage
    return "(未定)" if stage.blank?

    safe_join([
      content_tag(:span, stage.name, class: "text-slate-900"),
      stage_color_badge(stage)
    ].compact)
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
