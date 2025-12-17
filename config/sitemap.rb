SitemapGenerator::Sitemap.default_host = "https://fesready.com"

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: "daily", priority: 1.0
end