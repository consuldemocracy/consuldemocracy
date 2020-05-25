class AddBudgetIdToInvestments < ActiveRecord::Migration[4.2]
  def change
    add_reference :budget_investments, :budget, index: true
  end
end
