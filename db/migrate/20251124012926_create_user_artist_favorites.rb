class CreateUserArtistFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :user_artist_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_artist_favorites, [ :user_id, :artist_id ], unique: true
  end
end
