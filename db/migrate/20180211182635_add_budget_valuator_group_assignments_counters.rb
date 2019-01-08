class AddBudgetValuatorGroupAssignmentsCounters < ActiveRecord::Migration
  def change
    add_column :budget_investments, :valuator_group_assignments_count, :integer, default: 0
    add_column :valuator_groups, :budget_investments_count, :integer, default: 0
  end
end
