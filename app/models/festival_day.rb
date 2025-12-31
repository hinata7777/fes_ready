class FestivalDay < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :festival_id }

  scope :for_user, ->(user) { FestivalDays::ForUserQuery.call(user: user) }

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
end
