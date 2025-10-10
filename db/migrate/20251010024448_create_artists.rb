class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.string :name, null: false
      t.string :spotify_artist_id
      t.string :image_url

      t.timestamps null: false
    end

    add_index :artists, :name

    if ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
      add_index :artists,
                :spotify_artist_id,
                unique: true,
                where: "spotify_artist_id IS NOT NULL",
                name: "index_artists_on_spotify_artist_id_unique_when_present"
    else
      add_index :artists, :spotify_artist_id, unique: true
    end
  end
end
