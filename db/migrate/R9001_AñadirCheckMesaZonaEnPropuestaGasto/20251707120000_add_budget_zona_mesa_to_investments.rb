class AddBudgetZonaMesaToInvestments < ActiveRecord::Migration[4.2]
  def change
	add_column :budget_investment, :zona_mesa, :boolean, default: false
    add_index :budget_investment, :zona_mesa
  end
end
