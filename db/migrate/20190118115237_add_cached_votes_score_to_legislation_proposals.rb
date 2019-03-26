class AddCachedVotesScoreToLegislationProposals < ActiveRecord::Migration
  def change
    add_column :legislation_proposals, :cached_votes_score, :integer, default: 0

    add_index :legislation_proposals, :cached_votes_score
  end
end
