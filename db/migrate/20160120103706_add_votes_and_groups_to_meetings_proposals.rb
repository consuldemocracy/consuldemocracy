class AddVotesAndGroupsToMeetingsProposals < ActiveRecord::Migration
  def change
    add_column :meetings_proposals, :votes, :integer
    add_column :meetings_proposals, :groups, :string
  end
end
