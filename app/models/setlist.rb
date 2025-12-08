class Setlist < ApplicationRecord
  belongs_to :stage_performance

  has_many :setlist_songs, dependent: :destroy
  has_many :songs, through: :setlist_songs

  validates :stage_performance, presence: true, uniqueness: true

  accepts_nested_attributes_for :setlist_songs, allow_destroy: true

  def to_param
    uuid.presence || super
  end
end
