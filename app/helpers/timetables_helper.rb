module TimetablesHelper
  PerformanceBlock = Struct.new(
    :top_percent,
    :height_percent,
    :start_label,
    :end_label,
    :artist_name,
    keyword_init: true
  )

  def timeline_performance_block(performance, timeline_start:, timeline_end:, timezone:, column_height:)
    start_time = align_time_to_day(performance.starts_at, timeline_start, timezone)
    return unless start_time

    end_time =
      align_time_to_day(performance.ends_at, timeline_start, timezone) ||
      start_time + 30.minutes

    return if end_time <= timeline_start || start_time >= timeline_end

    clipped_start = [start_time, timeline_start].max
    clipped_end   = [end_time,   timeline_end].min
    return if clipped_end <= clipped_start

    total_minutes      = (timeline_end - timeline_start) / 60.0
    duration_minutes   = [(clipped_end - clipped_start) / 60.0, 15].max
    offset_minutes     = [((clipped_start - timeline_start) / 60.0), 0].max

    top_percent        = ((offset_minutes / total_minutes) * 100).clamp(0, 100)
    remaining_percent  = [100 - top_percent, 0].max
    block_percent      = (duration_minutes / total_minutes) * 100

    min_block_height_px = 24.0
    min_height_percent  = (min_block_height_px / column_height) * 100
    block_height_px     = (block_percent / 100.0) * column_height

    adjusted_percent =
      if block_height_px < min_block_height_px
        [min_height_percent, remaining_percent].min
      else
        block_percent
      end

    height_percent = [adjusted_percent, remaining_percent].min

    PerformanceBlock.new(
      top_percent:   top_percent,
      height_percent: height_percent,
      start_label:   start_time.strftime("%H:%M"),
      end_label:     end_time&.strftime("%H:%M"),
      artist_name:   performance.artist.name
    )
  end

  private

  def align_time_to_day(time, timeline_start, timezone)
    return unless time

    day   = timeline_start.to_date
    local = time.in_time_zone(timezone)
    timezone.local(day.year, day.month, day.day, local.hour, local.min, local.sec)
  end
end
