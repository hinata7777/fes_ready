class Setlist < ApplicationRecord
  belongs_to :stage_performance

  has_many :setlist_songs, dependent: :destroy
  has_many :songs, through: :setlist_songs

  validates :stage_performance, presence: true, uniqueness: true
end
