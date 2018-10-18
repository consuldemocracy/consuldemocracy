class AddApprovalVotingFields < ActiveRecord::Migration
  def change
    add_column :budgets, :voting_style, :string, default: 'knapsack'
    add_column :budgets, :money_bounded, :boolean, default: true
    add_column :budget_headings, :max_votes, :integer, default: 1
    
    # add_column :budget_groups, :voting_cant_exceed_heading_budget, :boolean, default: true
    # add_column :budget_groups, :number_votes_per_heading, :int, default: 1
  end
end
