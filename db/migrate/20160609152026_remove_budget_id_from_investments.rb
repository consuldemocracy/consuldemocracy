class RemoveBudgetIdFromInvestments < ActiveRecord::Migration
  def change
    remove_column :budget_investments, :budget_id, :integer
  end
end
