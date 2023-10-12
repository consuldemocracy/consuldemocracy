class AddShowInvestmentsToBudgets < ActiveRecord::Migration[6.0]
  def change
    add_column :budgets, :show_investments, :boolean, default: false
  end
end

