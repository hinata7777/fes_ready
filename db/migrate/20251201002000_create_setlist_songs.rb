class CreateSetlistSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :setlist_songs do |t|
      t.references :setlist, null: false, foreign_key: true
      t.references :song,    null: false, foreign_key: true
      t.integer    :position, null: false
      t.text       :note

      t.timestamps null: false
    end

    add_index :setlist_songs, [ :setlist_id, :position ], unique: true
  end
end
