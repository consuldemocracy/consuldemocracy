class AddTrackerAssignmentsCountToBudgetInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :tracker_assignments_count, :integer
  end
end
