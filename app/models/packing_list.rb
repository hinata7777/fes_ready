class PackingList < ApplicationRecord
  belongs_to :user, optional: true

  has_many :packing_list_items, dependent: :destroy
  has_many :items, through: :packing_list_items

  scope :templates, -> { where(template: true) }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  validates :title, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true, unless: :template?
  validates :template, inclusion: { in: [ true, false ] }
end
