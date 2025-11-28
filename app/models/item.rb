class Item < ApplicationRecord
  belongs_to :user, optional: true

  has_many :packing_list_items, dependent: :destroy, inverse_of: :item
  has_many :packing_lists, through: :packing_list_items

  scope :templates, -> { where(template: true) }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  validates :name, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true, unless: :template?
  validates :template, inclusion: { in: [ true, false ] }
end
