class AddPriceToBudget < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :price, :integer
  end
end
