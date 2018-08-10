class AddVotingStyleAndNumberVotesPerHeadingToGroups < ActiveRecord::Migration
  def change
    add_column :budget_groups, :voting_style, :string, default: 'knapsack'
    add_column :budget_groups, :number_votes_per_heading, :int, default: 1
  end
end
