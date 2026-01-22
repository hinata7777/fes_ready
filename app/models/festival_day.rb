class FestivalDay < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :festival_id }
  validate :date_within_festival_range, if: -> { date.present? && festival.present? && festival.start_date.present? && festival.end_date.present? }

  scope :for_user, ->(user) {
    joins(:festival, stage_performances: :user_timetable_entries)
      .where(user_timetable_entries: { user_id: user.id })
      .includes(:festival)
      .distinct
      # 一覧表示で「フェス開始日 → 日程」の順に揃える
      .order("festivals.start_date ASC", "festival_days.date ASC")
  }

  scope :upcoming, ->(today = Date.current) {
    joins(:festival).where("festivals.end_date >= ?", today)
  }

  scope :ordered_for_select, -> {
    joins(:festival).order("festivals.start_date ASC", "festival_days.date ASC")
  }

  scope :for_packing_list_select, ->(today = Date.current) {
    upcoming(today).includes(:festival).ordered_for_select
  }

  def finished?(today = Date.current)
    festival.end_date < today
  end

  private

  def date_within_festival_range
    range = festival.start_date..festival.end_date
    return if range.cover?(date)

    errors.add(:date, "開催日はフェスの開催期間内である必要があります（#{festival.start_date}〜#{festival.end_date}）")
  end
end
