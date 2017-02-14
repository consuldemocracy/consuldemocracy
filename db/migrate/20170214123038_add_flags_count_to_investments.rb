class AddFlagsCountToInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :flags_count, :integer, default: 0
  end
end
