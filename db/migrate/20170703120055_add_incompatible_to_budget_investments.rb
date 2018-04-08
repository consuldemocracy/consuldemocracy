class AddIncompatibleToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :incompatible, :bool, default: false, index: true
  end
end
