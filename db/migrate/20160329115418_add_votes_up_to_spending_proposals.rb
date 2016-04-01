class AddVotesUpToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :cached_votes_up, :integer, default: 0
  end
end
