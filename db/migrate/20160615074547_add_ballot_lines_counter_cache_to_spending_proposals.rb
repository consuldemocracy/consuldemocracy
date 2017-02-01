class AddBallotLinesCounterCacheToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :ballot_lines_count, :integer, default: 0
  end
end
