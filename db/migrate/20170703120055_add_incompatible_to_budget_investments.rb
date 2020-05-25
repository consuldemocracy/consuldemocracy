class AddIncompatibleToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :incompatible, :bool, default: false, index: true
  end
end
