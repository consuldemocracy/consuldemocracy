class AddJoinedSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :joined_to_spending_proposal_id, :int
  end
end
