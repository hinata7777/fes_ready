class CreateUserTimetableEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :user_timetable_entries do |t|
      t.references :user,              null: false, foreign_key: true
      t.references :stage_performance, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :user_timetable_entries, [:user_id, :stage_performance_id], unique: true, name: "idx_user_timetable_entries_uniqueness"
  end
end