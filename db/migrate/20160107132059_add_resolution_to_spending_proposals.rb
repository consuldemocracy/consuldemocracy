class AddResolutionToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :resolution, :string, default: nil
    add_index :spending_proposals, :resolution
  end
end
