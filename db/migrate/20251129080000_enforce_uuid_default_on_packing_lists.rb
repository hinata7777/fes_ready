class EnforceUuidDefaultOnPackingLists < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    change_column_default :packing_lists, :uuid, -> { "gen_random_uuid()" }
    change_column_null :packing_lists, :uuid, false
  end
end
