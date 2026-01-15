class TimelineLayoutPresenter
  # 出演枠の表示に必要な位置・高さ・ラベル情報
  PerformanceBlock = Struct.new(
    :top_percent,
    :height_percent,
    :start_label,
    :end_label,
    :artist_name,
    keyword_init: true
  )

  # タイムラインの目盛り線（位置と時刻）
  MarkerLine = Struct.new(:top_percent, :time, keyword_init: true)

  # タイムラインの目盛りラベル（位置・文字・配置）
  MarkerLabel = Struct.new(:time, :top_percent, :placement, :label_text, keyword_init: true) do
    def css_translation_class
      case placement
      when :start then "translate-y-0"
      when :end then "-translate-y-full"
      else "-translate-y-1/2"
      end
    end
  end

  # タイムライン全体の開始/終了と表示用サイズ情報
  attr_reader :timeline_start, :timeline_end, :timezone, :hour_height_px, :duration_seconds, :column_height_px

  def initialize(timeline_start:, timeline_end:, timezone:, hour_height_px: 120)
    @timeline_start = timeline_start
    @timeline_end   = timeline_end
    @timezone       = timezone
    @hour_height_px = hour_height_px
    @duration_seconds = [ ((timeline_end - timeline_start) / 1.second).to_i, 3600 ].max
    @column_height_px = [ (@duration_seconds / 3600.0) * hour_height_px, hour_height_px ].max
  end

  def marker_lines(markers)
    # 1時間ごとの線を「上から何％」の位置に変換する
    markers.filter_map do |marker_time|
      next if marker_time <= timeline_start
      offset_ratio_value = timeline_offset_ratio(marker_time)
      next unless offset_ratio_value && offset_ratio_value <= 1
      MarkerLine.new(time: marker_time, top_percent: to_percent(offset_ratio_value))
    end
  end

  def marker_labels(markers)
    # 目盛りラベルの位置と表示文字列を計算する
    marker_count = markers.size
    markers.each_with_index.filter_map do |marker_time, index|
      offset_ratio_value = timeline_offset_ratio(marker_time)
      next unless offset_ratio_value && offset_ratio_value >= 0 && offset_ratio_value <= 1
      label_position = label_placement(index, marker_count)
      MarkerLabel.new(
        time: marker_time,
        top_percent: to_percent(offset_ratio_value),
        placement: label_position,
        label_text: format_time_label(marker_time)
      )
    end
  end

  def performance_block(performance)
    # 出演枠を「縦位置・高さ（％）」に変換して表示用データを作る
    performance_start_time, performance_end_time = performance_times(performance)
    return unless performance_start_time

    clipped_window = clip_to_timeline(performance_start_time, performance_end_time)
    return unless clipped_window

    block_top_percent, block_height_percent = block_geometry(clipped_window[:start], clipped_window[:end])

    PerformanceBlock.new(
      top_percent: block_top_percent,
      height_percent: block_height_percent,
      start_label: format_time_label(performance_start_time),
      end_label: format_time_label(performance_end_time),
      artist_name: performance.artist.name
    )
  end

  private

  def timeline_offset_ratio(point_in_time)
    # タイムライン全体に対する経過割合（0.0〜1.0）を計算する
    return unless point_in_time
    elapsed_seconds = (point_in_time - timeline_start) / duration_seconds.to_f
    elapsed_seconds if elapsed_seconds >= 0 && elapsed_seconds <= 1
  end

  def to_percent(value)
    # 0.0〜1.0 を 0〜100 の百分率に変換する
    (value * 100).clamp(0, 100)
  end

  def duration_minutes
    # タイムライン全体の長さ（分）
    duration_seconds / 60.0
  end

  def align_time_to_day(time)
    # タイムゾーンを揃えて時刻を扱う
    return unless time
    time.in_time_zone(timezone)
  end

  def format_time_label(time)
    # 表示用のHH:MMラベルを作る（当日0時からの経過時間で表示）
    return unless time
    hours_from_day_start, minutes = label_hours_and_minutes(time)
    format("%02d:%02d", hours_from_day_start, minutes)
  end

  def day_start_reference
    # その日の0時を基準にする
    @day_start_reference ||= timeline_start.in_time_zone(timezone).beginning_of_day
  end

  def clip_to_timeline(start_time, end_time)
    # タイムライン範囲外の出演枠は切り捨て、表示対象部分だけを返す
    return if end_time <= timeline_start || start_time >= timeline_end

    clipped_start = [ start_time, timeline_start ].max
    clipped_end   = [ end_time, timeline_end ].min
    return if clipped_end <= clipped_start

    { start: clipped_start, end: clipped_end }
  end

  def block_geometry(clipped_start, clipped_end)
    # 出演枠の開始/終了から「縦位置・高さ（％）」を計算する
    timeline_minutes = duration_minutes
    block_minutes, minutes_from_timeline_start = block_duration_and_offset_minutes(clipped_start, clipped_end)

    block_top_percent = to_percent(minutes_from_timeline_start / timeline_minutes)
    remaining_height_percent = [ 100 - block_top_percent, 0 ].max
    block_height_percent = to_percent(block_minutes / timeline_minutes)

    final_height_percent = adjusted_block_height_percent(
      block_height_percent,
      remaining_height_percent
    )

    [ block_top_percent, final_height_percent ]
  end

  def label_placement(index, marker_count)
    # 先頭・末尾だけラベル位置をずらす
    if index.zero?
      :start
    elsif index == marker_count - 1
      :end
    else
      :middle
    end
  end

  def performance_times(performance)
    # 出演枠の開始/終了時刻をタイムゾーンに揃える
    start_time = align_time_to_day(performance.starts_at)
    return [ nil, nil ] unless start_time

    end_time = align_time_to_day(performance.ends_at) || start_time + 30.minutes
    [ start_time, end_time ]
  end

  def label_hours_and_minutes(time)
    # ラベル表示用の「経過時間（時）+ 分」を計算する
    local_time = time.in_time_zone(timezone)
    hours_from_day_start = ((local_time - day_start_reference) / 1.hour).floor
    hours_from_day_start = [ hours_from_day_start, 0 ].max
    [ hours_from_day_start, local_time.min ]
  end

  def block_duration_and_offset_minutes(clipped_start, clipped_end)
    # 出演枠の長さと開始位置（分）を求める
    block_minutes = [ ((clipped_end - clipped_start) / 60.0), 15 ].max
    minutes_from_timeline_start = [ ((clipped_start - timeline_start) / 60.0), 0 ].max
    [ block_minutes, minutes_from_timeline_start ]
  end

  def adjusted_block_height_percent(block_height_percent, remaining_height_percent)
    # 最小高さを保証しつつ、残り領域を超えない高さに調整する
    min_block_height_px = 24.0
    min_height_percent  = (min_block_height_px / column_height_px) * 100
    block_height_px     = (block_height_percent / 100.0) * column_height_px

    adjusted_height_percent =
      if block_height_px < min_block_height_px
        [ min_height_percent, remaining_height_percent ].min
      else
        block_height_percent
      end

    [ adjusted_height_percent, remaining_height_percent ].min
  end
end
