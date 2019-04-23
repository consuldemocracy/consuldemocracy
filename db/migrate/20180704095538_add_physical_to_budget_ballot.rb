class AddPhysicalToBudgetBallot < ActiveRecord::Migration
  def change
    add_column :budget_ballots, :physical, :boolean, default: false
    add_column :budget_ballots, :poll_ballot_id, :integer
  end
end
