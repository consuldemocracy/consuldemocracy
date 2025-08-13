class AddBudgetZonaMesaToInvestments < ActiveRecord::Migration[4.2]
  def change
	add_column :budget_investments, :zona_mesa, :boolean, default: false
    add_index :budget_investments, :zona_mesa
  end
end
