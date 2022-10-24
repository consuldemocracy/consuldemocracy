class AddBudgetToPolls < ActiveRecord::Migration[4.2]
  def change
    add_reference :polls, :budget, index: { unique: true }, foreign_key: true
  end
end
