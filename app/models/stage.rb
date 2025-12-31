class Stage < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy
  validates :name, presence: true

  validates :color_key, inclusion: { in: StageColor.valid_keys }, allow_nil: true

  def color_hex
    StageColor.hex_for(color_key)
  end
end
