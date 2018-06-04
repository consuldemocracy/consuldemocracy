class AddBudgetToPolls < ActiveRecord::Migration
  def change
    add_reference :polls, :budget, index: { unique: true }, foreign_key: true
  end
end
