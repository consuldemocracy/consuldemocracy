class EnforceSpUniquenessInDb < ActiveRecord::Migration
  def change
    remove_index :ballot_lines, [:ballot_id, :spending_proposal_id]
    add_index :ballot_lines, [:ballot_id, :spending_proposal_id], unique: true
  end
end
