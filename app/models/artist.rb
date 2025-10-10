class Artist < ApplicationRecord
  validates :name, presence: true

  # SpotifyのIDは Base62 22文字（例: 0OdUWJ0sBjDrqHygGUXeCF）
  validates :spotify_artist_id,
           format: { with: /\A[0-9A-Za-z]{22}\z/, message: "is invalid (22-char base62)" },
           allow_blank: true,
           uniqueness: true

  # 将来: has_many :performances など
end
