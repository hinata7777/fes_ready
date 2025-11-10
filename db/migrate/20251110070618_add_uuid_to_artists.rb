class AddUuidToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :uuid, :uuid
  end
end
