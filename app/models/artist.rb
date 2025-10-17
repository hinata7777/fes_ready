class Artist < ApplicationRecord
  validates :name, presence: true

  has_many :stage_performances, dependent: :destroy
  has_many :festival_days, through: :stage_performances
  has_many :festivals, -> { distinct }, through: :festival_days

  def self.ransackable_attributes(_ = nil); %w[name]; end
  def self.ransackable_associations(_ = nil); []; end

  # SpotifyのIDは Base62 22文字（例: 0OdUWJ0sBjDrqHygGUXeCF）
  validates :spotify_artist_id,
           format: { with: /\A[0-9A-Za-z]{22}\z/, message: "is invalid (22-char base62)" },
           allow_blank: true,
           uniqueness: true

  # 将来: has_many :performances など
end
