class FestivalDay < ApplicationRecord
  belongs_to :festival
  validates :date, presence: true
  validates :date, uniqueness: { scope: :festival_id }
end
