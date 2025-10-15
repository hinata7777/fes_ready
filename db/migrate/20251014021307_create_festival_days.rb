class CreateFestivalDays < ActiveRecord::Migration[8.0]
  def change
    create_table :festival_days do |t|
      t.references :festival, null: false, foreign_key: true
      t.date     :date,    null: false
      t.datetime :doors_at
      t.datetime :start_at
      t.datetime :end_at
      t.string   :note
      t.timestamps
    end
    add_index :festival_days, [ :festival_id, :date ], unique: true
  end
end
