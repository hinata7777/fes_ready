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

  # セットリスト一覧で表示する日付サブテキスト用
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

  # prep/festivals の詳細で埋め込み or 代替メッセージを表示する
  def spotify_embed_block(song, empty_message: "Spotify未登録の曲です", height: 152, css_class: nil)
    embed = spotify_embed_for(song, height: height, css_class: css_class)
    return embed if embed.present?

    content_tag(:p, empty_message, class: "text-xs text-slate-500")
  end

  # prep/artist 詳細のランキング表示に渡すlocalsをまとめる
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
