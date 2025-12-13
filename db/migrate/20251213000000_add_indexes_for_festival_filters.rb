class AddIndexesForFestivalFilters < ActiveRecord::Migration[8.0]
  def change
    add_index :festivals, :end_date
    add_index :festivals, :prefecture

    # 補助インデックス: タグ側からフェスを引くときの並びを最適化
    add_index :festival_festival_tags, [ :festival_tag_id, :festival_id ]
  end
end
