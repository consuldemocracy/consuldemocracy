class AddBallotLineCounterCachedToBallots < ActiveRecord::Migration
  def change
    add_column :ballots, :ballot_lines_count, :integer, default: 0
  end
end
