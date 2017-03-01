class AddCachedBallotsUpToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :cached_ballots_up, :integer, null: false, default: 0
  end
end
