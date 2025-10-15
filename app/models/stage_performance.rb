class StagePerformance < ApplicationRecord
  enum :status, { draft: 0, scheduled: 1 }

  belongs_to :festival_day
  belongs_to :stage, optional: true
  belongs_to :artist

  # scheduledのときだけ必須＆妥当性チェック
  with_options if: :scheduled? do
    validates :stage,     presence: true
    validates :starts_at, presence: true
    validates :ends_at,   presence: true
    validate  :ends_after_starts
  end

  scope :chronological, -> { order(:starts_at) }
  scope :for_day,       ->(day_id)    { where(festival_day_id: day_id) }
  scope :for_stage,     ->(stage_id)  { where(stage_id: stage_id) }
  scope :for_artist,    ->(artist_id) { where(artist_id: artist_id) }

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "は開始より後にしてください") if ends_at <= starts_at
  end
end
