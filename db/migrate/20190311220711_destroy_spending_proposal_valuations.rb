class DestroySpendingProposalValuations < ActiveRecord::Migration[4.2]
  def change
    drop_table :valuation_assignments
  end
end
