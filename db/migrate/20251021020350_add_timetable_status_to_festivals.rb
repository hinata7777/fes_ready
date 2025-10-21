class AddTimetableStatusToFestivals < ActiveRecord::Migration[8.0]
  def change
    add_column :festivals, :timetable_published, :boolean, null: false, default: false
    add_index  :festivals, :timetable_published
  end
end
