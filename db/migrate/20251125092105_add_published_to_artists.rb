class AddPublishedToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :published, :boolean, default: true, null: false
    add_index :artists, :published
  end
end
