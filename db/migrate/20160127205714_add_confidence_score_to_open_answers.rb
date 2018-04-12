class AddConfidenceScoreToOpenAnswers < ActiveRecord::Migration
  def change
    add_column :open_answers, :confidence_score, :integer, default: 0
  end
end
