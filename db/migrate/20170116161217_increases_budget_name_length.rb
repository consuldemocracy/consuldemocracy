class IncreasesBudgetNameLength < ActiveRecord::Migration
  def up
    change_column :budgets, :name, :string, limit: 50
  end

  def down
    change_column :budgets, :name, :string, limit: 30
  end
end
