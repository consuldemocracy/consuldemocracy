class RemoveDefaultValueForRandomSeedBallots < ActiveRecord::Migration
  def change
    change_column_default :budget_ballots, :random_seed, nil
  end
end
