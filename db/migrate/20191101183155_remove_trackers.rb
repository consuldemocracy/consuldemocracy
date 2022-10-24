class RemoveTrackers < ActiveRecord::Migration[5.0]
  def up
    remove_column :budget_investments, :tracker_assignments_count, :integer
    drop_table :budget_tracker_assignments
    drop_table :budget_trackers
    drop_table :trackers
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
