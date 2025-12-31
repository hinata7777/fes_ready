class Artist < ApplicationRecord
  include Uuidable

  validates :name, presence: true, uniqueness: true

  scope :published, -> { where(published: true) }

  has_many :stage_performances, dependent: :destroy
  has_many :festival_days, through: :stage_performances
  has_many :festivals, -> { distinct }, through: :festival_days
  has_many :songs, dependent: :restrict_with_exception
  has_many :user_artist_favorites, dependent: :destroy
  has_many :favorited_users, through: :user_artist_favorites, source: :user

  def self.find_by_identifier!(identifier)
    find_by(uuid: identifier) || find(identifier)
  end

  def self.find_published!(identifier)
    published.find_by(uuid: identifier) || published.find(identifier)
  end

  def self.ransackable_attributes(_ = nil); %w[name]; end
  def self.ransackable_associations(_ = nil); []; end

  scope :favorited_by, ->(user) {
    joins(:user_artist_favorites)
      .where(user_artist_favorites: { user_id: user.id })
      .order(:name)
  }

  # 空文字・前後空白を取り除いて nil 正規化
  normalizes :spotify_artist_id, with: ->(v) { v&.strip.presence }

  # SpotifyのIDは Base62 22文字（例: 0OdUWJ0sBjDrqHygGUXeCF）
  validates :spotify_artist_id,
           format: { with: /\A[0-9A-Za-z]{22}\z/, message: "is invalid (22-char base62)" },
           allow_nil: true,
           uniqueness: { allow_nil: true }

  # 将来: has_many :performances など

  def favorited_by?(user)
    return false unless user
    user_artist_favorites.exists?(user_id: user.id)
  end
end
