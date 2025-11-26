class CreatePackingLists < ActiveRecord::Migration[8.0]
  def change
    create_table :packing_lists do |t|
      t.references :user, null: true, foreign_key: true
      t.string :title, null: false
      t.boolean :template, null: false, default: false
      t.string :template_name

      t.timestamps null: false
    end

    add_index :packing_lists, :template
    add_index :packing_lists, [ :user_id, :title ], unique: true, name: "index_packing_lists_on_user_and_title_when_owned", where: "user_id IS NOT NULL"
  end
end
