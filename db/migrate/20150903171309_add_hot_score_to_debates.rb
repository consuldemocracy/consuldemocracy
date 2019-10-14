class AddHotScoreToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :hot_score, :bigint, default: 0
  end
end
