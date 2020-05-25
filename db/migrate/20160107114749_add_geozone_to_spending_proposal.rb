class AddGeozoneToSpendingProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :geozone_id, :integer, default: nil
    add_index :spending_proposals, :geozone_id
  end
end
