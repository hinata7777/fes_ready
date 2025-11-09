class AddUuidToUsers < ActiveRecord::Migration[8.0]
  def up
    # gen_random_uuid() を使うための拡張（DBに1回だけ有効化すればOK）
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # 1) まず追加（NULL許容・defaultなし）
    add_column :users, :uuid, :uuid

    # 2) 既存レコードそれぞれにUUID採番（行ごとに関数が評価されて全員ユニークになる）
    execute "UPDATE users SET uuid = gen_random_uuid() WHERE uuid IS NULL;"

    # 3) 空欄禁止
    change_column_null :users, :uuid, false

    # 4) 今後のINSERTは自動採番
    change_column_default :users, :uuid, "gen_random_uuid()"

    # 5) 重複禁止（ユニークインデックス）
    add_index :users, :uuid, unique: true, name: "index_users_on_uuid"
  end

  def down
    remove_index :users, name: "index_users_on_uuid"
    change_column_default :users, :uuid, nil
    remove_column :users, :uuid
  end
end
