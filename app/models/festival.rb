class Festival < ApplicationRecord
  include Favoritable
  favoritable_by :user_festival_favorites
  attribute :status_filter, :string
  enum :status_filter, { upcoming: "upcoming", past: "past" }, scopes: false

  has_many :festival_days, dependent: :destroy, inverse_of: :festival
  has_many :stages,        dependent: :destroy, inverse_of: :festival
  has_many :user_festival_favorites, dependent: :destroy
  has_many :favorited_users, through: :user_festival_favorites, source: :user
  has_many :festival_festival_tags, dependent: :destroy
  has_many :festival_tags, through: :festival_festival_tags

  accepts_nested_attributes_for :festival_days, allow_destroy: true
  accepts_nested_attributes_for :stages,        allow_destroy: true

  validates :name, :slug, :start_date, :end_date, :timezone, presence: true
  validates :slug, uniqueness: true
  validate  :end_not_before_start

  scope :ordered,  -> { order(start_date: :asc, name: :asc) }
  scope :upcoming, ->(today = Date.current) { where("end_date >= ?", today) }
  scope :past,     ->(today = Date.current) { where("end_date < ?",  today) }
  scope :with_published_timetable, -> { where(timetable_published: true) }
  scope :with_slug, ->(slug) { where(slug: slug) }

  before_validation -> { self.official_url = official_url&.strip.presence }

  def self.ransackable_attributes(_ = nil); %w[name]; end
  def self.ransackable_associations(_ = nil); []; end

  VALID_URL = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  validates :official_url, allow_blank: true,
            format: { with: VALID_URL, message: "は http/https の正しいURL形式で入力してください" }

  def to_param
    slug.presence || super
  end

  def self.find_by_slug!(slug, scope: all)
    scope.find_by!(slug: slug)
  end

  def timetable_days
    festival_days.order(:date)
  end

  def stage_performances_on(festival_day)
    return StagePerformance.none if festival_day.blank?
    raise ArgumentError, "festival_day must belong to festival" if festival_day.festival_id != id

    festival_day.stage_performances
                .includes(:stage, :artist)
                .order(:starts_at)
  end

  def artists_for_day(festival_day)
    return Artist.none if festival_day.blank? || festival_day.festival_id != id

    Artist
      .joins(stage_performances: :festival_day)
      .where(stage_performances: { festival_day_id: festival_day.id })
      .merge(Artist.published)
      .distinct
      .order(:name)
  end

  private

  def end_not_before_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "は開始日以降にしてください") if end_date < start_date
  end
end
