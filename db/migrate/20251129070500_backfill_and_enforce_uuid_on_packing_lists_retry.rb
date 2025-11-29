class BackfillAndEnforceUuidOnPackingListsRetry < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 新規作成分がNULLにならないよう先にデフォルトを付与
    change_column_default :packing_lists, :uuid, -> { "gen_random_uuid()" }

    # 既存のNULLをバックフィル
    execute <<~SQL
      UPDATE packing_lists
      SET uuid = gen_random_uuid()
      WHERE uuid IS NULL;
    SQL

    # 残っていれば異常として止める
    remaining = select_value("SELECT COUNT(*) FROM packing_lists WHERE uuid IS NULL").to_i
    raise StandardError, "uuid backfill failed (#{remaining} rows remain)" if remaining.positive?

    # NOT NULL 制約
    change_column_null :packing_lists, :uuid, false
  end

  def down
    change_column_null :packing_lists, :uuid, true
    change_column_default :packing_lists, :uuid, nil
  end
end
