# db/migrate/20251109063637_add_uuid_to_users.rb
class AddUuidToUsers < ActiveRecord::Migration[8.0]
  def up
    # gen_random_uuid() を使うための拡張（冪等）
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # users.uuid カラムを追加（存在しない場合のみ）
    unless column_exists?(:users, :uuid, :uuid)
      add_column :users, :uuid, :uuid
    end

    # 既存レコードにUUIDを採番（NULLのものだけ）
    execute <<~SQL
      UPDATE users
      SET uuid = gen_random_uuid()
      WHERE uuid IS NULL;
    SQL

    # NOT NULL 制約
    change_column_null :users, :uuid, false

    # 以降のINSERTは自動採番（★ProcでSQL関数を渡す）
    change_column_default :users, :uuid, -> { "gen_random_uuid()" }

    # ユニークインデックス（未作成なら）
    unless index_exists?(:users, :uuid, name: "index_users_on_uuid", unique: true)
      add_index :users, :uuid, unique: true, name: "index_users_on_uuid"
    end
  end

  def down
    # 逆順で安全に戻す
    remove_index :users, name: "index_users_on_uuid" if index_exists?(:users, :uuid, name: "index_users_on_uuid")
    change_column_default :users, :uuid, nil if column_exists?(:users, :uuid)
    remove_column :users, :uuid if column_exists?(:users, :uuid)
  end
end
