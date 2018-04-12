class AddHelpToBudgetPolls < ActiveRecord::Migration
  def change
    add_column :budget_polls, :help, :boolean
  end
end
