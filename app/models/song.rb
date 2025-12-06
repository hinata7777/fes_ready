class Song < ApplicationRecord
  belongs_to :artist
  has_many :setlist_songs, dependent: :restrict_with_exception
  has_many :setlists, through: :setlist_songs

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
    base = value.to_s.strip
    # Unicode正規化が利用可能なら実行（環境によってunicode_normalize拡張が無い場合がある）
    base = base.unicode_normalize(:nfkc) if base.respond_to?(:unicode_normalize)

    base.mb_chars
        .downcase
        .to_s
        .gsub(/\s+/, " ")
  end

  private

  def set_normalized_name
    return if name.blank?
    self.normalized_name = self.class.normalize_name(name)
  end
end
