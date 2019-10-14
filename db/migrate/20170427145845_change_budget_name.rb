class ChangeBudgetName < ActiveRecord::Migration
  def up
    change_column :budgets, :name, :string, limit: 80
  end

  def down
    change_column :budgets, :name, :string
  end
end
