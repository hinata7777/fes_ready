class CreateSetlists < ActiveRecord::Migration[8.0]
  def change
    create_table :setlists do |t|
      t.references :stage_performance, null: false, foreign_key: true, index: { unique: true }

      t.timestamps null: false
    end
  end
end
