class MakeCommentsConfidenceScoreDefaultTo0 < ActiveRecord::Migration
  def change
    change_column :comments, :confidence_score, :integer, default: 0, null: false, index: true
  end
end
