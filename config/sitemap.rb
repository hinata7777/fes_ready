SitemapGenerator::Sitemap.default_host = "https://fesready.com"

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: "daily", priority: 1.0
  add guide_path, changefreq: "monthly", priority: 0.4
  add terms_path, changefreq: "yearly", priority: 0.2
  add privacy_path, changefreq: "yearly", priority: 0.2
  add operator_path, changefreq: "yearly", priority: 0.2
  add contact_path, changefreq: "yearly", priority: 0.2

  add festivals_path, changefreq: "daily", priority: 0.8
  add artists_path, changefreq: "daily", priority: 0.8
  add timetables_path, changefreq: "daily", priority: 0.7
  add prep_festivals_path, changefreq: "daily", priority: 0.7
  add prep_artists_path, changefreq: "daily", priority: 0.7

  Festival.find_each do |festival|
    add festival_path(festival), changefreq: "weekly", priority: 0.6
    add prep_festival_path(festival), changefreq: "weekly", priority: 0.6
  end

  Artist.published.find_each do |artist|
    add artist_path(artist), changefreq: "weekly", priority: 0.6
    add prep_artist_path(artist), changefreq: "weekly", priority: 0.6
  end
end
