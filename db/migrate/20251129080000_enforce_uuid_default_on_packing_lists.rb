class EnforceUuidDefaultOnPackingLists < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # テーブルが空の前提なので一旦カラムを落として作り直す
    if column_exists?(:packing_lists, :uuid)
      remove_column :packing_lists, :uuid
    end

    add_column :packing_lists, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_index  :packing_lists, :uuid, unique: true
  end

  def down
    remove_index  :packing_lists, :uuid if index_exists?(:packing_lists, :uuid)
    remove_column :packing_lists, :uuid if column_exists?(:packing_lists, :uuid)
  end
end
