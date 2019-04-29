class AddUniqIndexForBallotLines < ActiveRecord::Migration[4.2]
  def change
    add_index :budget_ballot_lines, [:ballot_id, :investment_id], unique: true
  end
end
