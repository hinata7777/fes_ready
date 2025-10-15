class FestivalDay < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :festival_id }
end
