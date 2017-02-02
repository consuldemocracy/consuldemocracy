class ExpandNombreInBudgets < ActiveRecord::Migration
  def change
    change_column :budgets, :name, :string, limit: 80
  end
end
