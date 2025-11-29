class AddUuidToPackingListsAgain < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    add_column :packing_lists, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" } unless column_exists?(:packing_lists, :uuid)
    add_index  :packing_lists, :uuid, unique: true unless index_exists?(:packing_lists, :uuid)
  end
end
