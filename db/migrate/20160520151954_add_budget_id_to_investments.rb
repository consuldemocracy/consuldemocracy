class AddBudgetIdToInvestments < ActiveRecord::Migration
  def change
    add_reference :budget_investments, :budget, index: true
  end
end
