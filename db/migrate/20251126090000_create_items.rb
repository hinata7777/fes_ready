class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :category
      t.boolean :template, null: false, default: false

      t.timestamps null: false
    end

    add_index :items, :template
    add_index :items, [ :user_id, :name ], unique: true, name: "index_items_on_user_and_name_when_owned", where: "user_id IS NOT NULL"
  end
end
