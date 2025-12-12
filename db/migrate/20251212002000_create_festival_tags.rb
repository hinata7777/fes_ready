class CreateFestivalTags < ActiveRecord::Migration[8.0]
  def change
    create_table :festival_tags do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :festival_tags, :name, unique: true

    create_table :festival_festival_tags do |t|
      t.references :festival, null: false, foreign_key: true
      t.references :festival_tag, null: false, foreign_key: true

      t.timestamps
    end
    add_index :festival_festival_tags, [ :festival_id, :festival_tag_id ], unique: true
  end
end
