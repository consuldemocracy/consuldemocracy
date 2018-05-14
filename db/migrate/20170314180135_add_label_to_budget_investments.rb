class AddLabelToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :label, :string, default: nil
  end
end
