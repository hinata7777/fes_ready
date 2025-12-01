class AddCanceledToStagePerformances < ActiveRecord::Migration[7.1]
  def change
    add_column :stage_performances, :canceled, :boolean, null: false, default: false
  end
end
