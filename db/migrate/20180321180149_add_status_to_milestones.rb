class AddStatusToMilestones < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_column :budget_investment_milestones, :status_id, :integer
    add_index :budget_investment_milestones, :status_id, algorithm: :concurrently
  end
end
