class AddPhysicalVotesToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :physical_votes, :integer, default: 0
  end
end
