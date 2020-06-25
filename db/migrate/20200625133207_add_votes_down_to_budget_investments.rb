class AddVotesDownToBudgetInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_investments, :cached_votes_down, :integer, default: 0
    add_column :budget_investments, :cached_votes_total, :integer, default: 0

    add_index  :budget_investments, :cached_votes_down
    add_index  :budget_investments, :cached_votes_total
  end
end
