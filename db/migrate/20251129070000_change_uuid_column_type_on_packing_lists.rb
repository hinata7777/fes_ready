class ChangeUuidColumnTypeOnPackingLists < ActiveRecord::Migration[8.0]
  def up
    # string で作成済みの uuid カラムを uuid 型に変更
    change_column :packing_lists, :uuid, :uuid, using: "uuid::uuid"
  end

  def down
    # 旧来の string 型に戻す
    change_column :packing_lists, :uuid, :string
  end
end
