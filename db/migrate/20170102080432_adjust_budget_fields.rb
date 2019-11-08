class AdjustBudgetFields < ActiveRecord::Migration[4.2]
  def change
    change_column :budgets, :phase, :string, limit: 40, default: "accepting"
  end
end
