class Stage < ApplicationRecord
  belongs_to :festival
  validates :name, presence: true

  # 任意: 屋内/屋外など（UIは後で）
  enum :environment, { unspecified: 0, outdoor: 1, indoor: 2 }, 
  prefix: true, 
  default: 0

  COLOR_PALETTE = {
    "red"      => "#F95858",
    "emerald"  => "#10B981",
    "blue"     => "#3B82F6",
    "amber"    => "#F59E0B",
    "violet"   => "#8B5CF6",
    "slate"    => "#64748B",
  }.freeze

  validates :color_key, inclusion: { in: COLOR_PALETTE.keys }, allow_nil: true

  def color_hex
    COLOR_PALETTE[color_key.presence || "slate"]
  end
end