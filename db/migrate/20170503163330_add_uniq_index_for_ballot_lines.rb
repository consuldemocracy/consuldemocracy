class AddUniqIndexForBallotLines < ActiveRecord::Migration
  def change
    add_index :budget_ballot_lines, [:ballot_id, :investment_id], unique: true
  end
end
