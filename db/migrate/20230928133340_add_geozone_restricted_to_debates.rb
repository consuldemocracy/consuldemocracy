class AddGeozoneRestrictedToDebates < ActiveRecord::Migration[6.1]
  def change
    add_column :debates, :geozone_restricted, :boolean, default: false
  end
end
