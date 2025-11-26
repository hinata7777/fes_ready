class PackingListItem < ApplicationRecord
  belongs_to :packing_list
  belongs_to :item

  validates :item_id, uniqueness: { scope: :packing_list_id }
  validates :checked, inclusion: { in: [ true, false ] }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
