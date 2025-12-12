class Stage < ApplicationRecord
  belongs_to :festival
  has_many :stage_performances, dependent: :destroy
  validates :name, presence: true

  COLOR_PALETTE = {
    "red"      => "#F95858",
    "emerald"  => "#10B981",
    "blue"     => "#3B82F6",
    "amber"    => "#F59E0B",
    "violet"   => "#8B5CF6",
    "slate"    => "#64748B"
  }.freeze

  validates :color_key, inclusion: { in: COLOR_PALETTE.keys }, allow_nil: true

  def color_hex
    COLOR_PALETTE[color_key.presence || "slate"]
  end
end
