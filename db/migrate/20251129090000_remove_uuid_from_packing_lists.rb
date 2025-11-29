class RemoveUuidFromPackingLists < ActiveRecord::Migration[8.0]
  def change
    remove_index :packing_lists, :uuid if index_exists?(:packing_lists, :uuid)
    remove_column :packing_lists, :uuid if column_exists?(:packing_lists, :uuid)
  end
end
