class BackfillAndEnforceUuidOnUsers < ActiveRecord::Migration[8.0]
  # 並列インデックス作成のため、このマイグレーションはトランザクション外で実行
  disable_ddl_transaction!

  def up
    # gen_random_uuid() を使うための拡張（未有効なら有効化）
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 1) 既存の NULL を埋める（行ごとに関数評価→全員ユニーク）
    execute <<~SQL
      UPDATE users
      SET uuid = gen_random_uuid()
      WHERE uuid IS NULL;
    SQL

    # 2) NOT NULL 制約を付与（※ここは短時間のロックが入ります）
    change_column_null :users, :uuid, false

    # 3) ユニークインデックスを並列作成（未作成なら）
    add_index :users, :uuid,
              unique: true,
              name: "index_users_on_uuid",
              algorithm: :concurrently unless index_exists?(:users, :uuid, name: "index_users_on_uuid", unique: true)
  end

  def down
    # 巻き戻し：インデックス削除 → NOT NULL 解除（値は残す）
    remove_index :users, name: "index_users_on_uuid" if index_exists?(:users, :uuid, name: "index_users_on_uuid")
    change_column_null :users, :uuid, true
  end
end
