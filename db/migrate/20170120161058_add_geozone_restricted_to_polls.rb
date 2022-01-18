class AddGeozoneRestrictedToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :geozone_restricted, :boolean, default: false
  end
end
