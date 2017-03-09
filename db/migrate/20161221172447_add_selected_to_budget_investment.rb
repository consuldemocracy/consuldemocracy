class AddSelectedToBudgetInvestment < ActiveRecord::Migration
  def change
    add_column :budget_investments, :selected, :bool, default: false, index: true
  end
end
