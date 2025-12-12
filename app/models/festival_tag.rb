class FestivalTag < ApplicationRecord
  has_many :festival_festival_tags, dependent: :destroy
  has_many :festivals, through: :festival_festival_tags

  validates :name, presence: true, uniqueness: true
end
