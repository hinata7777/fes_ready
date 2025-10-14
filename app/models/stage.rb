class Stage < ApplicationRecord
  belongs_to :festival
  validates :name, presence: true

  # 任意: 屋内/屋外など（UIは後で）
  enum :environment, { unspecified: 0, outdoor: 1, indoor: 2 }, prefix: true, _default: 0
end