class CreateFestivals < ActiveRecord::Migration[8.0]
  def change
    create_table :festivals do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :venue_name
      t.string :city
      t.string :prefecture
      t.date   :start_date, null: false
      t.date   :end_date,   null: false
      t.string :timezone,   null: false, default: 'Asia/Tokyo'
      t.timestamps
    end
    add_index :festivals, :slug, unique: true
    add_index :festivals, :start_date
  end
end
