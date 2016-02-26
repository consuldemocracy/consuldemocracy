class AddAssignmentsCounterCacheToSpendingProposal < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :valuation_assignments_count, :integer, default: 0
  end
end
