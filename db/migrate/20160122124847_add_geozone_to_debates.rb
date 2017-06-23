class AddGeozoneToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :geozone_id, :integer, default: nil
    add_index :debates, :geozone_id
  end
end
