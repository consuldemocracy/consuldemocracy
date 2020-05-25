class AddCachedVotesScoreToDebate < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :cached_votes_score, :integer, default: 0

    add_index :debates, :cached_votes_score
  end
end
