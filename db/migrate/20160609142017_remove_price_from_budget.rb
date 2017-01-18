class RemovePriceFromBudget < ActiveRecord::Migration
  def change
    remove_column :budgets, :price, :integer
  end
end
