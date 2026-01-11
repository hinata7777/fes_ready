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

  def sorted_tags
    festival_tags.order(:name)
  end

  def select_day(date_param, days: festival_days)
    raise ActiveRecord::RecordNotFound if days.blank?
    return days.first if date_param.blank?

    parsed = Date.parse(date_param)
    if days.respond_to?(:find_by!)
      days.find_by!(date: parsed)
    else
      days.find { |day| day.date == parsed } || raise(ActiveRecord::RecordNotFound)
    end
  rescue ArgumentError
    raise ActiveRecord::RecordNotFound
  end

  def stage_performances_on(festival_day)
    Festivals::StagePerformancesForDayQuery.call(
      festival: self,
      festival_day: festival_day
    )
  end

  def artists_for_day(festival_day)
    Festivals::ArtistsForDayQuery.call(
      festival: self,
      festival_day: festival_day
    )
  end

  # セットリスト一覧への導線を出せるか判定
  def setlists_available?
    Setlist.joins(stage_performance: :festival_day)
           .where(festival_days: { festival_id: id })
           .exists?
  end

  def setlists_visible?(today = Date.current)
    start_date.present? && start_date <= today && setlists_available?
  end

  private

  def end_not_before_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "は開始日以降にしてください") if end_date < start_date
  end
end
