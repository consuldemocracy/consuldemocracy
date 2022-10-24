class AddTimestampsToBudgetGroups < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :budget_groups, null: true
  end
end
