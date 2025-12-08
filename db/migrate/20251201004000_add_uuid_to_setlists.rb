class AddUuidToSetlists < ActiveRecord::Migration[7.1]
  def change
    add_column :setlists, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_index  :setlists, :uuid, unique: true
  end
end
