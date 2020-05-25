class ChangeBudgetName < ActiveRecord::Migration[4.2]
  def up
    change_column :budgets, :name, :string, limit: 80
  end

  def down
    change_column :budgets, :name, :string
  end
end
