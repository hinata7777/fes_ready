class Song < ApplicationRecord
  belongs_to :artist

  normalizes :spotify_id, with: ->(v) { v&.strip.presence }

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :normalized_name, presence: true
  validates :artist, presence: true

  # SpotifyのトラックIDは Base62 22文字（例: 0OdUWJ0sBjDrqHygGUXeCF）
  validates :spotify_id,
            format: { with: /\A[0-9A-Za-z]{22}\z/, message: "is invalid (22-char base62)" },
            allow_nil: true

  validates :normalized_name, uniqueness: { scope: :artist_id }

  def self.normalize_name(value)
    value.to_s.mb_chars.normalize(:nfkc).downcase.strip.gsub(/\s+/, " ")
  end

  private

  def set_normalized_name
    return if name.blank?
    self.normalized_name = self.class.normalize_name(name)
  end
end
