require "securerandom"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, { general: 0, admin: 1 }

  validates :nickname, presence: true, length: { maximum: 10 }
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  has_many :user_timetable_entries, dependent: :destroy
  has_many :my_stage_performances, through: :user_timetable_entries, source: :stage_performance
  has_many :user_festival_favorites, dependent: :destroy
  has_many :favorite_festivals, through: :user_festival_favorites, source: :festival
  has_many :user_artist_favorites, dependent: :destroy
  has_many :favorite_artists, through: :user_artist_favorites, source: :artist
  has_many :items, dependent: :destroy
  has_many :packing_lists, dependent: :destroy

  before_create :ensure_uuid!

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_by(email: auth.info.email)

    nickname = user&.nickname.presence || sanitized_nickname(auth)

    user ||= new(
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      nickname: nickname
    )

    user.assign_attributes(provider: auth.provider, uid: auth.uid, nickname: nickname)
    user.save!
    user
  end

  def self.create_unique_string
    SecureRandom.uuid
  end

  def picked?(stage_performance)
    user_timetable_entries.exists?(stage_performance_id: stage_performance.id)
  end

  def stage_performance_ids_for_day(festival_day)
    user_timetable_entries
      .joins(:stage_performance)
      .where(stage_performances: { festival_day_id: festival_day.id })
      .pluck(:stage_performance_id)
  end

  def to_param
    uuid
  end

  private

  def ensure_uuid!
    self.uuid ||= SecureRandom.uuid
  end

  def self.sanitized_nickname(auth)
    nickname = auth.info.name.presence || auth.info.first_name.presence || auth.info.email.split("@").first
    nickname.to_s[0, 10]
  end
  private_class_method :sanitized_nickname
end
