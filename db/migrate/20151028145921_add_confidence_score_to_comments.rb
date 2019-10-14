class AddConfidenceScoreToComments < ActiveRecord::Migration
  def change
    add_column :comments, :confidence_score, :integer, index: true
  end
end
