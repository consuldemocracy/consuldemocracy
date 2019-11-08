class DestroySpendingProposalValuations < ActiveRecord::Migration[4.2]
  def up
    drop_table :valuation_assignments
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
