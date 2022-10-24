class DestroySpendingProposals < ActiveRecord::Migration[4.2]
  def up
    drop_table :spending_proposals
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
