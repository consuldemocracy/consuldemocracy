class AddConfidenceScoreToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :confidence_score, :integer, default: 0
    add_index :debates, :confidence_score
  end
end
