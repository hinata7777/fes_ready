class SetlistSong < ApplicationRecord
  belongs_to :setlist
  belongs_to :song

  validates :setlist, presence: true
  validates :song, presence: true

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :position, uniqueness: { scope: :setlist_id }
end
