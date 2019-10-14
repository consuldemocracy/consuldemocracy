class AddHotScoreIndexToDebates < ActiveRecord::Migration
  def change
    add_index(:debates, :hot_score)
  end
end
