class Festival < ApplicationRecord
  attribute :status_filter, :string
  enum :status_filter, { upcoming: "upcoming", past: "past" }, scopes: false

  has_many :festival_days, dependent: :destroy, inverse_of: :festival
  has_many :stages,        dependent: :destroy, inverse_of: :festival
  has_many :user_festival_favorites, dependent: :destroy
  has_many :favorited_users, through: :user_festival_favorites, source: :user

  accepts_nested_attributes_for :festival_days, allow_destroy: true
  accepts_nested_attributes_for :stages,        allow_destroy: true

  validates :name, :slug, :start_date, :end_date, :timezone, presence: true
  validates :slug, uniqueness: true
  validate  :end_not_before_start

  scope :ordered,  -> { order(start_date: :asc, name: :asc) }
  scope :upcoming, ->(today = Date.current) { where("start_date >= ?", today) }
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

  def self.status_labels
    status_filters.keys.index_with do |key|
      I18n.t("enums.festival.status_filter.#{key}", default: key.humanize)
    end
  end

  def self.default_status
    status_filters.keys.first
  end

  def self.normalized_status(value)
    candidate = value.to_s
    status_filters.key?(candidate) ? candidate : default_status
  end

  def self.for_status(status, reference_date: Date.current)
    normalized = normalized_status(status)
    relation = normalized == "past" ? past(reference_date) : upcoming(reference_date)
    relation.merge(ordered)
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
      .distinct
      .order(:name)
  end

  # 指定したユーザーがお気に入り済みかどうかを判定するヘルパー
  def favorited_by?(user)
    return false unless user
    user_festival_favorites.exists?(user_id: user.id)
  end

  private

  def end_not_before_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "は開始日以降にしてください") if end_date < start_date
  end
end
