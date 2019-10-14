class AddResolutionToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :resolution, :string, default: nil
    add_index :spending_proposals, :resolution
  end
end
