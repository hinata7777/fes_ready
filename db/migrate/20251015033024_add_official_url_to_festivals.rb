class AddOfficialUrlToFestivals < ActiveRecord::Migration[8.0]
  def change
    add_column :festivals, :official_url, :string
  end
end
