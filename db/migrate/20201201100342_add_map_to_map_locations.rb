class AddMapToMapLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :map_locations, :map_id, :integer
  end
end
