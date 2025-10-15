class CreateStagePerformances < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'btree_gist' unless extension_enabled?('btree_gist')

    create_table :stage_performances do |t|
      t.references :festival_day, null: false, foreign_key: true
      t.references :stage,        null: true, foreign_key: true
      t.references :artist,       null: false, foreign_key: true
      t.datetime   :starts_at,    null: true
      t.datetime   :ends_at,      null: true
      t.integer    :status,       null: false, default: 0
      t.timestamps
    end

    # “その日に同じアーティストを重複登録しない”用（下書き/確定どちらでも有効）
    add_index :stage_performances, [ :festival_day_id, :artist_id ], unique: true

    # 実用インデックス
    add_index :stage_performances, [ :festival_day_id, :stage_id, :starts_at ]
    add_index :stage_performances, [ :artist_id, :starts_at ]

    # 確定済み(scheduled)のみ適用するユニーク制約（同じ枠の二重登録防止）
    execute <<~SQL
      CREATE UNIQUE INDEX uniq_sp_slot_when_scheduled
      ON stage_performances (festival_day_id, stage_id, artist_id, starts_at)
      WHERE status = 1 AND stage_id IS NOT NULL AND starts_at IS NOT NULL;
    SQL

    # 同一ステージでの時間帯重複を禁止（確定済みのみ／半開区間）
    execute <<~SQL
      ALTER TABLE stage_performances
        ADD CONSTRAINT no_overlap_on_same_stage_when_scheduled
        EXCLUDE USING gist (
          stage_id WITH =,
          tsrange(starts_at, ends_at, '[)') WITH &&
        )
        WHERE (
          status = 1
          AND stage_id IS NOT NULL
          AND starts_at IS NOT NULL
          AND ends_at IS NOT NULL
        );
    SQL
  end
end
