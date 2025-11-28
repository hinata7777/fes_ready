class PackingListItem < ApplicationRecord
  belongs_to :packing_list, inverse_of: :packing_list_items
  belongs_to :item, inverse_of: :packing_list_items, autosave: true

  accepts_nested_attributes_for :item

  validates :item_id, uniqueness: { scope: :packing_list_id }
  validates :checked, inclusion: { in: [ true, false ] }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
