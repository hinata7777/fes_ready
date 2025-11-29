class AddUuidToPackingListsAgain < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    add_column :packing_lists, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_index  :packing_lists, :uuid, unique: true
  end
end
