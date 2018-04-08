class AddRelatedContentScoresCounterToRelatedContent < ActiveRecord::Migration
  def change
    add_column :related_contents, :related_content_scores_count, :integer, default: 0
  end
end
