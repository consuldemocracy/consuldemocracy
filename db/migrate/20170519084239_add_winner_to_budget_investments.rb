class AddWinnerToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :winner, :boolean, default: false
  end
end
