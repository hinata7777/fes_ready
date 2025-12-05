class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.string     :name,             null: false
      t.string     :normalized_name,  null: false
      t.references :artist,           null: false, foreign_key: true
      t.string     :spotify_id

      t.timestamps null: false
    end

    add_index :songs, :spotify_id
    add_index :songs, %i[artist_id normalized_name], unique: true
  end
end
