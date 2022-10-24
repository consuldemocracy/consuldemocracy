class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :comments, :confidence_score
    add_index :users, :gender
    add_index :users, :date_of_birth
    add_index :budget_ballot_lines, :budget_id
    add_index :budget_ballot_lines, :group_id
    add_index :budget_ballot_lines, :heading_id
    add_index :budget_investments, :budget_id
    add_index :budget_investments, :group_id
    add_index :budget_investments, :selected
    add_index :polls, :geozone_restricted
    add_index :failed_census_calls, :poll_officer_id
    add_index :budget_investments, :incompatible
    add_index :proposals, :selected
  end
end
