class AdjustBudgetFields < ActiveRecord::Migration
  def change
    change_column :budgets, :phase, :string, limit: 40, default: 'accepting'
  end
end
