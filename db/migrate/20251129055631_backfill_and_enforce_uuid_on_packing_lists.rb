class BackfillAndEnforceUuidOnPackingLists < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    PackingList.where(uuid: [ nil, "" ]).find_in_batches(batch_size: 1000) do |batch|
      batch.each { |pl| pl.update_columns(uuid: SecureRandom.uuid) }
    end

    change_column_default :packing_lists, :uuid, -> { "gen_random_uuid()" }
    change_column_null :packing_lists, :uuid, false
  end

  def down
    change_column_null :packing_lists, :uuid, true
    change_column_default :packing_lists, :uuid, nil
    # バックフィル分は戻さない想定
  end
end
