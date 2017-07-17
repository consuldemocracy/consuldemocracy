class AddIndexToBallotLineSpendingProposalId < ActiveRecord::Migration
  def change
    add_index :ballot_lines, :spending_proposal_id
    add_index :ballot_lines, [:ballot_id, :spending_proposal_id]
  end
end
