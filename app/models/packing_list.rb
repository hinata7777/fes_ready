class PackingList < ApplicationRecord
  belongs_to :user, optional: true

  has_many :packing_list_items, dependent: :destroy, inverse_of: :packing_list
  has_many :items, through: :packing_list_items

  accepts_nested_attributes_for :packing_list_items, allow_destroy: true

  scope :templates, -> { where(template: true) }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  validates :title, presence: true, length: { maximum: 100 }
  validates :title, uniqueness: { scope: :user_id, message: "は既に存在します" }, unless: :template?
  validates :user_id, presence: true, unless: :template?
  validates :template, inclusion: { in: [ true, false ] }

  def to_param
    uuid.presence || super
  end
end
