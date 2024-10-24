class AddPhysicalVotesToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :physical_votes, :integer, default: 0
  end
end
