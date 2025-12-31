class StageColor
  # ActiveRecordではなく、色定義だけを持つ値オブジェクト
  PALETTE = {
    "red"      => "#F95858",
    "emerald"  => "#10B981",
    "blue"     => "#3B82F6",
    "amber"    => "#F59E0B",
    "violet"   => "#8B5CF6",
    "slate"    => "#64748B"
  }.freeze

  DEFAULT_KEY = "slate"

  def self.valid_keys
    PALETTE.keys
  end

  def self.hex_for(color_key)
    PALETTE[color_key.presence || DEFAULT_KEY]
  end
end
