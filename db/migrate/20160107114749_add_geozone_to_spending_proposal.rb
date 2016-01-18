class AddGeozoneToSpendingProposal < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :geozone_id, :integer, default: nil
    add_index :spending_proposals, :geozone_id
  end
end
