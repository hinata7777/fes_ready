class Festival < ApplicationRecord
  has_many :festival_days, dependent: :destroy, inverse_of: :festival
  has_many :stages,        dependent: :destroy, inverse_of: :festival

  accepts_nested_attributes_for :festival_days, allow_destroy: true
  accepts_nested_attributes_for :stages,        allow_destroy: true

  validates :name, :slug, :start_date, :end_date, :timezone, presence: true
  validates :slug, uniqueness: true
  validate  :end_not_before_start

  before_validation -> { self.official_url = official_url&.strip.presence }

  VALID_URL = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  validates :official_url, allow_blank: true,
            format: { with: VALID_URL, message: "は http/https の正しいURL形式で入力してください" }

  private

  def end_not_before_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "は開始日以降にしてください") if end_date < start_date
  end
end
