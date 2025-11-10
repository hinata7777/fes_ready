class BackfillAndEnforceUuidOnArtists < ActiveRecord::Migration[8.0]
  # 並列でインデックスを貼るため、トランザクションを無効化
  disable_ddl_transaction!

  def up
    # gen_random_uuid() を使うための拡張（未有効なら有効化）
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 1) 既存のNULLを一気に埋める（行ごとに関数評価され全員ユニーク）
    execute <<~SQL
      UPDATE artists
      SET uuid = gen_random_uuid()
      WHERE uuid IS NULL;
    SQL

    # 2) NOT NULL 制約
    change_column_null :artists, :uuid, false

    # 3) ユニークインデックス（未作成なら並列で作成）
    add_index :artists, :uuid,
              unique: true,
              name: "index_artists_on_uuid",
              algorithm: :concurrently unless index_exists?(:artists, :uuid, name: "index_artists_on_uuid", unique: true)
  end

  def down
    # 巻き戻し：インデックス削除 → NOT NULL解除（値は残す）
    remove_index :artists, name: "index_artists_on_uuid" if index_exists?(:artists, :uuid, name: "index_artists_on_uuid")
    change_column_null :artists, :uuid, true
  end
end
