module SetlistsHelper
  def stage_time_label(stage_performance)
    return "未定" if stage_performance.blank?

    parts = []
    parts << stage_performance.stage&.name

    starts_at = stage_performance.starts_at
    ends_at   = stage_performance.ends_at

    if starts_at.present? && ends_at.present?
      parts << "#{starts_at.strftime('%H:%M')}〜#{ends_at.strftime('%H:%M')}"
    elsif starts_at.present?
      parts << "#{starts_at.strftime('%H:%M')}〜"
    end

    label = parts.compact.reject(&:blank?).join(" / ")
    label.presence || "未定"
  end

  def setlist_entries(setlist_songs, artist)
    setlist_songs.filter_map do |setlist_song|
      song = setlist_song.song
      next unless song

      {
        setlist_song: setlist_song,
        song: song,
        embed: spotify_embed_for(song),
        artist: artist
      }
    end
  end
end
