class AddPhysicalVotesToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :physical_votes, :integer, default: 0
  end
end
