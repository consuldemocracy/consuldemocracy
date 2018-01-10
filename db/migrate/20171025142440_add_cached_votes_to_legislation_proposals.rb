class AddCachedVotesToLegislationProposals < ActiveRecord::Migration
  def change
    add_column :legislation_proposals, :cached_votes_total, :integer, default: 0
    add_column :legislation_proposals, :cached_votes_down, :integer, default: 0
  end
end
