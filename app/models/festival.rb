class Festival < ApplicationRecord
  has_many :festival_days, dependent: :destroy, inverse_of: :festival
  has_many :stages,        dependent: :destroy, inverse_of: :festival

  accepts_nested_attributes_for :festival_days, allow_destroy: true
  accepts_nested_attributes_for :stages,        allow_destroy: true

  validates :name, :slug, :start_date, :end_date, :timezone, presence: true
  validates :slug, uniqueness: true
  validate  :end_not_before_start

  scope :ordered,  -> { order(start_date: :asc, name: :asc) }
  scope :upcoming, ->(today = Date.current) { where("start_date >= ?", today) }
  scope :past,     ->(today = Date.current) { where("end_date < ?",  today) }
  scope :with_published_timetable, -> { where(timetable_published: true) }

  before_validation -> { self.official_url = official_url&.strip.presence }

  def self.ransackable_attributes(_=nil); %w[name]; end
  def self.ransackable_associations(_=nil); []; end
  
  VALID_URL = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  validates :official_url, allow_blank: true,
            format: { with: VALID_URL, message: "は http/https の正しいURL形式で入力してください" }

  def timetable_days
    festival_days.order(:date)
  end

  def stage_performances_for(day_or_date)
    day =
      if day_or_date.is_a?(FestivalDay)
        day_or_date
      else
        festival_days.find_by!(date: day_or_date)
      end
    day.stage_performances
       .includes(:stage, :artist)
       .order(:starts_at)
  end

  private
  
  def end_not_before_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "は開始日以降にしてください") if end_date < start_date
  end
end