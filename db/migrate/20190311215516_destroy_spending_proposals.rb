class DestroySpendingProposals < ActiveRecord::Migration
  def change
    drop_table :spending_proposals
  end
end
