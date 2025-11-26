class CreatePackingListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :packing_list_items do |t|
      t.references :packing_list, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.boolean :checked, null: false, default: false
      t.integer :position, null: false, default: 0
      t.string :note

      t.timestamps null: false
    end

    add_index :packing_list_items, [ :packing_list_id, :item_id ], unique: true, name: "index_packing_list_items_on_list_and_item"
    add_index :packing_list_items, [ :packing_list_id, :position ]
  end
end
