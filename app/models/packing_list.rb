class PackingList < ApplicationRecord
  include TemplateOwned

  include Uuidable

  belongs_to :user, optional: true
  belongs_to :festival_day, optional: true

  has_many :packing_list_items, dependent: :destroy, inverse_of: :packing_list
  has_many :items, through: :packing_list_items

  accepts_nested_attributes_for :packing_list_items, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :title, uniqueness: { scope: :user_id, message: "は既に存在します" }, unless: :template?
  validate :festival_day_must_be_upcoming_if_changed

  def past_selected_festival_day(today = Date.current)
    return unless festival_day
    festival_day if festival_day.finished?(today)
  end

  private

  def festival_day_must_be_upcoming_if_changed
    return unless will_save_change_to_festival_day_id?
    return if festival_day.blank?
    errors.add(:festival_day, "は開催前の日程を選んでください") if festival_day.finished?
  end
end
