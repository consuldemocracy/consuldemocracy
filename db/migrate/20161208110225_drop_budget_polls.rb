class DropBudgetPolls < ActiveRecord::Migration
  def change
    drop_table :budget_polls
  end
end
