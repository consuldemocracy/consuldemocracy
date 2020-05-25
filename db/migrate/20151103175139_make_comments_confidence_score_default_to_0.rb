class MakeCommentsConfidenceScoreDefaultTo0 < ActiveRecord::Migration[4.2]
  def change
    change_column :comments, :confidence_score, :integer, default: 0, null: false, index: true
  end
end
