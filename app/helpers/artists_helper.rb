module ArtistsHelper
  def ranking_badge_class(index)
    case index
    when 0
      "bg-gradient-to-br from-amber-300 via-amber-400 to-amber-200 text-white ring-2 ring-amber-200 shadow-lg"
    when 1
      "bg-gradient-to-br from-slate-200 via-slate-300 to-slate-100 text-slate-900 ring-2 ring-slate-200 shadow-lg"
    when 2
      "bg-gradient-to-br from-amber-800 via-orange-600 to-amber-500 text-white ring-2 ring-amber-300 shadow-lg"
    else
      "bg-indigo-500 text-white"
    end
  end

  def setlist_label(setlist)
    sp           = setlist.stage_performance
    festival     = sp.festival_day.festival
    festival.name
  end

  def setlist_subtext(setlist)
    setlist.stage_performance.festival_day.date.to_fs(:db)
  end

  def spotify_embed_for(song, height: 152, css_class: nil)
    return nil if song.spotify_id.blank?

    content_tag(
      :iframe,
      "",
      src: "https://open.spotify.com/embed/track/#{song.spotify_id}?utm_source=generator&theme=0",
      width: "100%",
      height: height.to_s,
      class: css_class,
      allowtransparency: true,
      allow: "autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture",
      loading: "lazy"
    )
  end

  def ranking_entry_locals(entry, index, artist)
    song  = entry[:song]
    embed = spotify_embed_for(song)
    {
      entry: entry,
      index: index,
      artist: artist,
      song: song,
      embed: embed
    }
  end
end
