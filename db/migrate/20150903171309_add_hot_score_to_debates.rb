class AddHotScoreToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :hot_score, :bigint, default: 0
  end
end
