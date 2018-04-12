class AddTimestampsToBudgetGroups < ActiveRecord::Migration
  def change
    add_timestamps :budget_groups, null: true
  end
end
