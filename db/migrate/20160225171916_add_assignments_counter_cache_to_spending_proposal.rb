class AddAssignmentsCounterCacheToSpendingProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :valuation_assignments_count, :integer, default: 0
  end
end
