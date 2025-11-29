class AddUuidToPackingLists < ActiveRecord::Migration[8.0]
  def change
    add_column :packing_lists, :uuid, :string
    add_index  :packing_lists, :uuid, unique: true
  end
end
