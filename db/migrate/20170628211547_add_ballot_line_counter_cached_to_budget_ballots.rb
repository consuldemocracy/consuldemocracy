class AddBallotLineCounterCachedToBudgetBallots < ActiveRecord::Migration
  def change
    add_column :budget_ballots, :ballot_lines_count, :integer, default: 0
  end
end
