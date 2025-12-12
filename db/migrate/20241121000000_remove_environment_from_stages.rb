class RemoveEnvironmentFromStages < ActiveRecord::Migration[8.0]
  def change
    remove_column :stages, :environment, :integer
  end
end
