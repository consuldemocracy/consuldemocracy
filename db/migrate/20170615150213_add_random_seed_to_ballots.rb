class AddRandomSeedToBallots < ActiveRecord::Migration
  def change
    add_column :budget_ballots, :random_seed, :float,  default: 'random()::float'
  end
end
