class AddSentimentToMlSummaryComments < ActiveRecord::Migration[7.1]
  def change
    add_column :ml_summary_comments, :sentiment_analysis, :jsonb
  end
end
