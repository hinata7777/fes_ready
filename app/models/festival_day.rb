class FestivalDay < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :festival_id }

  scope :for_user, ->(user) {
    joins(:festival, stage_performances: :user_timetable_entries)
      .where(user_timetable_entries: { user_id: user.id })
      .includes(:festival)
      .distinct
      .order("festivals.start_date ASC", "festival_days.date ASC")
  }
end
