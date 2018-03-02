class AddGeozoneIdToBallots < ActiveRecord::Migration
  def change
    add_column :ballots, :geozone_id, :integer
  end
end
