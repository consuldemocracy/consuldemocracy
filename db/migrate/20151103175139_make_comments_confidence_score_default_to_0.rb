class MakeCommentsConfidenceScoreDefaultTo0 < ActiveRecord::Migration[4.2]
  def up
    change_column :comments, :confidence_score, :integer, default: 0, null: false, index: true
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
