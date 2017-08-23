class AddWinnerToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :winner, :boolean, default: false
  end
end
