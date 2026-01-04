class StagePerformance < ApplicationRecord
  enum :status, { draft: 0, scheduled: 1 }

  belongs_to :festival_day
  belongs_to :stage, optional: true
  belongs_to :artist
  has_many :user_timetable_entries, dependent: :destroy
  has_one :setlist, dependent: :destroy

  # DB制約（scheduledのみ有効）
  # - 同一ステージでの時間帯重複を禁止（no_overlap_on_same_stage_when_scheduled）
  # - 同一スロットの二重登録を禁止（uniq_sp_slot_when_scheduled）
  # scheduledのときだけ必須＆妥当性チェック
  with_options if: :scheduled? do
    validates :stage,     presence: true
    validates :starts_at, presence: true
    validates :ends_at,   presence: true
    validate  :ends_after_starts
  end

  scope :for_day,       ->(day_id)    { day_id.present? ? where(festival_day_id: day_id) : all }
  scope :for_stage,     ->(stage_id)  { stage_id.present? ? where(stage_id: stage_id) : all }
  scope :for_artist,    ->(artist_id) { artist_id.present? ? where(artist_id: artist_id) : all }

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "は開始より後にしてください") if ends_at <= starts_at
  end
end
