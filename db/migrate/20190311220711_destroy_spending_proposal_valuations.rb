class DestroySpendingProposalValuations < ActiveRecord::Migration
  def change
    drop_table :valuation_assignments
  end
end
