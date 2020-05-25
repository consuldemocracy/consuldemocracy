class RemovePhysicalVotesFromProposals < ActiveRecord::Migration[4.2]
  def change
    remove_column :proposals, :physical_votes
  end
end
