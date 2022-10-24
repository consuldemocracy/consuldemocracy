class AddVotesUpToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :cached_votes_up, :integer, default: 0
  end
end
