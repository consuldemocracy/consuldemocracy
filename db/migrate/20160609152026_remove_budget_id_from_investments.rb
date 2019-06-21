class RemoveBudgetIdFromInvestments < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_investments, :budget_id, :integer
  end
end
