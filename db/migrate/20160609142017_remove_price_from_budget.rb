class RemovePriceFromBudget < ActiveRecord::Migration[4.2]
  def change
    remove_column :budgets, :price, :integer
  end
end
