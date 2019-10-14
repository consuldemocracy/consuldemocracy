class AddIgnoreFlagToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :ignored_flag_at, :datetime, default: nil
    add_column :budget_investments, :flags_count, :integer, default: 0
  end
end
