class AddSelectedToBudgetInvestment < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :selected, :bool, default: false
  end
end
