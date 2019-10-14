class RemovePhysicalVotesFromProposals < ActiveRecord::Migration
  def change
    remove_column :proposals, :physical_votes
  end
end
