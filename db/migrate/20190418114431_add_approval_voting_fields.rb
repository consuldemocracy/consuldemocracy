class AddApprovalVotingFields < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :voting_style, :string, default: "knapsack"
    add_column :budgets, :money_bounded, :boolean, default: true
    add_column :budget_headings, :max_votes, :integer, default: 1
  end
end
