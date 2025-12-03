class AddCoordinatesToFestivals < ActiveRecord::Migration[8.0]
  def change
    add_column :festivals, :latitude, :decimal, precision: 10, scale: 6
    add_column :festivals, :longitude, :decimal, precision: 10, scale: 6
    add_index :festivals, [ :latitude, :longitude ]
  end
end
