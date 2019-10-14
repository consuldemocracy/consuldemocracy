class AddGeozoneRestrictedToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :geozone_restricted, :boolean, default: false, index: true
  end
end
