class AddConfidenceScoreToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :confidence_score, :integer
  end
end
