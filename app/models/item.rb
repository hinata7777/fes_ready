class Item < ApplicationRecord
  include TemplateOwned

  belongs_to :user, optional: true

  has_many :packing_list_items, dependent: :destroy, inverse_of: :item
  has_many :packing_lists, through: :packing_list_items

  validates :name, presence: true, length: { maximum: 100 }
end
