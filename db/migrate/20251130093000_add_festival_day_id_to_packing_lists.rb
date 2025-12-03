class AddFestivalDayIdToPackingLists < ActiveRecord::Migration[8.0]
  def change
    add_reference :packing_lists, :festival_day, null: true, foreign_key: true
  end
end
