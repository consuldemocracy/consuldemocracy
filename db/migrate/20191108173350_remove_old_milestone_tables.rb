class RemoveOldMilestoneTables < ActiveRecord::Migration[5.0]
  def up
    drop_table :budget_investment_milestone_translations
    drop_table :budget_investment_statuses
    drop_table :budget_investment_milestones
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
