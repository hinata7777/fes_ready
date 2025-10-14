class CreateStages < ActiveRecord::Migration[8.0]
  def change
    create_table :stages do |t|
      t.references :festival, null: false, foreign_key: true
      t.string  :name,       null: false
      t.integer :sort_order, null: false, default: 0
      t.integer :environment
      t.string  :note
      t.string  :color_key
      t.timestamps
    end
    add_index :stages, [:festival_id, :sort_order]
  end
end
