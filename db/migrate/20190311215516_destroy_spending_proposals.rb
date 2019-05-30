class DestroySpendingProposals < ActiveRecord::Migration[4.2]
  def change
    drop_table :spending_proposals
  end
end
