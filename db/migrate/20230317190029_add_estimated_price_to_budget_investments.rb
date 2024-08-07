class AddEstimatedPriceToBudgetInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :budget_investments, :estimated_price, :bigint
  end
end
