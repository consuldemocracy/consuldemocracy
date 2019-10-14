class AddPollsRelatedIndexes < ActiveRecord::Migration
  def change

    add_index :poll_booth_assignments, :booth_id
    add_index :poll_booth_assignments, :poll_id

    add_index :poll_final_recounts, :officer_assignment_id

    add_index :poll_officer_assignments, :booth_assignment_id
    add_index :poll_officer_assignments, :officer_id
    add_index :poll_officer_assignments, [:officer_id, :date]

    add_index :poll_officers, :user_id

    add_index :poll_voters, :booth_assignment_id
    add_index :poll_voters, :officer_assignment_id

    add_index :polls, [:starts_at, :ends_at]


    add_foreign_key :poll_answers, :poll_questions, column: :question_id
    add_foreign_key :poll_booth_assignments, :polls
    add_foreign_key :poll_final_recounts, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_final_recounts, :poll_officer_assignments, column: :officer_assignment_id
    add_foreign_key :poll_null_results, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_null_results, :poll_officer_assignments, column: :officer_assignment_id
    add_foreign_key :poll_white_results, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_white_results, :poll_officer_assignments, column: :officer_assignment_id
    add_foreign_key :poll_officer_assignments, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_partial_results, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_partial_results, :poll_officer_assignments, column: :officer_assignment_id
    add_foreign_key :poll_voters, :polls
    add_foreign_key :poll_recounts, :poll_booth_assignments, column: :booth_assignment_id
    add_foreign_key :poll_recounts, :poll_officer_assignments, column: :officer_assignment_id
  end
end
