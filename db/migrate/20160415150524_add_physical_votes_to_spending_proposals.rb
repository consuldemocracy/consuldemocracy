class AddPhysicalVotesToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :physical_votes, :integer, default: 0
  end
end
