class BackfillAndEnforceUuidOnPackingLists < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 既存レコードを一括バックフィル（トランザクション内で確実に埋める）
    execute <<~SQL
      UPDATE packing_lists
      SET uuid = gen_random_uuid()
      WHERE uuid IS NULL OR uuid = '';
    SQL

    # 万が一残っていればここで検知して落とす
    remaining = select_value("SELECT COUNT(*) FROM packing_lists WHERE uuid IS NULL OR uuid = ''").to_i
    raise StandardError, "uuid backfill failed (#{remaining} rows remain)" if remaining.positive?

    change_column_default :packing_lists, :uuid, -> { "gen_random_uuid()" }
    change_column_null :packing_lists, :uuid, false
  end

  def down
    change_column_null :packing_lists, :uuid, true
    change_column_default :packing_lists, :uuid, nil
    # バックフィル分は戻さない想定
  end
end
