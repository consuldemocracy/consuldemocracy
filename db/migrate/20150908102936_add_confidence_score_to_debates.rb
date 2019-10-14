class AddConfidenceScoreToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :confidence_score, :integer, default: 0
    add_index :debates, :confidence_score
  end
end
