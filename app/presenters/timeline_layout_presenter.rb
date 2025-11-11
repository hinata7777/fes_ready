class TimelineLayoutPresenter
  PerformanceBlock = Struct.new(
    :top_percent,
    :height_percent,
    :start_label,
    :end_label,
    :artist_name,
    keyword_init: true
  )

  MarkerLine = Struct.new(:top_percent, :time, keyword_init: true)

  MarkerLabel = Struct.new(:time, :top_percent, :placement, keyword_init: true) do
    def css_translation_class
      case placement
      when :start then "translate-y-0"
      when :end then "-translate-y-full"
      else "-translate-y-1/2"
      end
    end

    def formatted_time(timezone)
      time.in_time_zone(timezone).strftime("%H:%M")
    end
  end

  attr_reader :timeline_start, :timeline_end, :timezone, :hour_height_px

  def initialize(timeline_start:, timeline_end:, timezone:, hour_height_px: 90)
    @timeline_start = timeline_start
    @timeline_end   = timeline_end
    @timezone       = timezone
    @hour_height_px = hour_height_px
    @duration_seconds = [((timeline_end - timeline_start) / 1.second).to_i, 3600].max
    @column_height_px = [(@duration_seconds / 3600.0) * hour_height_px, hour_height_px].max
  end

  def column_height_px
    @column_height_px
  end

  def duration_seconds
    @duration_seconds
  end

  def marker_lines(markers)
    markers.filter_map do |time|
      next if time <= timeline_start
      ratio = offset_ratio(time)
      next unless ratio && ratio <= 1
      MarkerLine.new(time: time, top_percent: percent(ratio))
    end
  end

  def marker_labels(markers)
    count = markers.size
    markers.each_with_index.filter_map do |time, index|
      ratio = offset_ratio(time)
      next unless ratio && ratio >= 0 && ratio <= 1
      placement =
        if index.zero?
          :start
        elsif index == count - 1
          :end
        else
          :middle
        end
      MarkerLabel.new(time: time, top_percent: percent(ratio), placement: placement)
    end
  end

  def performance_block(performance)
    start_time = align_time_to_day(performance.starts_at)
    return unless start_time

    end_time = align_time_to_day(performance.ends_at) || start_time + 30.minutes
    return if end_time <= timeline_start || start_time >= timeline_end

    clipped_start = [start_time, timeline_start].max
    clipped_end   = [end_time, timeline_end].min
    return if clipped_end <= clipped_start

    total_minutes = duration_minutes
    duration_minutes_value = [((clipped_end - clipped_start) / 60.0), 15].max
    offset_minutes = [((clipped_start - timeline_start) / 60.0), 0].max

    top_percent = percent(offset_minutes / total_minutes)
    remaining_percent = [100 - top_percent, 0].max
    block_percent = percent(duration_minutes_value / total_minutes)

    min_block_height_px = 24.0
    min_height_percent  = (min_block_height_px / column_height_px) * 100
    block_height_px     = (block_percent / 100.0) * column_height_px

    adjusted_percent =
      if block_height_px < min_block_height_px
        [min_height_percent, remaining_percent].min
      else
        block_percent
      end

    height_percent = [adjusted_percent, remaining_percent].min

    PerformanceBlock.new(
      top_percent: top_percent,
      height_percent: height_percent,
      start_label: start_time.strftime("%H:%M"),
      end_label: end_time&.strftime("%H:%M"),
      artist_name: performance.artist.name
    )
  end

  def percent_for_time(time)
    ratio = offset_ratio(time)
    ratio ? percent(ratio) : nil
  end

  private

  def offset_ratio(time)
    return unless time
    elapsed_seconds = (time - timeline_start) / duration_seconds.to_f
    elapsed_seconds if elapsed_seconds >= 0 && elapsed_seconds <= 1
  end

  def percent(number)
    (number * 100).clamp(0, 100)
  end

  def duration_minutes
    duration_seconds / 60.0
  end

  def align_time_to_day(time)
    return unless time

    day = timeline_start.to_date
    local = time.in_time_zone(timezone)
    timezone.local(day.year, day.month, day.day, local.hour, local.min, local.sec)
  end
end
