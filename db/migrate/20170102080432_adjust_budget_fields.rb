class AdjustBudgetFields < ActiveRecord::Migration[4.2]
  def up
    change_column :budgets, :phase, :string, limit: 40, default: "accepting"
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
