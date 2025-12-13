module XShareHelper
  def x_intent_url(text:, url:)
    "https://twitter.com/intent/tweet?text=#{ERB::Util.url_encode(text + "\n")}&url=#{ERB::Util.url_encode(url)}"
  end

  def artist_prep_share_url(artist)
    hashtag_artist = artist.name.to_s.gsub(/\s+/, "")
    text = "FES READYで#{artist.name}の楽曲を予習中！\n#FESREADY ##{hashtag_artist}"
    x_intent_url(text: text, url: prep_artist_url(artist))
  end

  def my_timetable_share_url(festival:, day:, owner_uuid:)
    text = "FES READYで #{festival.name} のマイタイムテーブルを作成しました！\n#FESREADY"
    url  = festival_my_timetable_url(festival, date: day.to_s, user_id: owner_uuid)
    x_intent_url(text: text, url: url)
  end
end
