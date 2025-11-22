class CreateUserFestivalFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :user_festival_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :festival, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_festival_favorites, [ :user_id, :festival_id ], unique: true
  end
end
