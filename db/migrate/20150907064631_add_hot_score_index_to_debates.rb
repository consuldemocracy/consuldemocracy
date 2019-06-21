class AddHotScoreIndexToDebates < ActiveRecord::Migration[4.2]
  def change
    add_index(:debates, :hot_score)
  end
end
