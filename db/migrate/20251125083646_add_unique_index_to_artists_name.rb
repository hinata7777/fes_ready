class AddUniqueIndexToArtistsName < ActiveRecord::Migration[8.0]
  def change
    remove_index :artists, :name if index_exists?(:artists, :name)
    add_index :artists, :name, unique: true
  end
end
