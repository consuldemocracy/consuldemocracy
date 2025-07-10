class AddPhysicalToBudgetBallot < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_ballots, :physical, :boolean, default: false
    add_column :budget_ballots, :poll_ballot_id, :integer
  end
end
