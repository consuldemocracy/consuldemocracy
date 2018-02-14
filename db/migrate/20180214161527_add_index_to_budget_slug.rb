class AddIndexToBudgetSlug < ActiveRecord::Migration
  def change
    add_index :budgets, :slug
  end
end
