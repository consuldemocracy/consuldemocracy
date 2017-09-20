class RemovePollWhiteResult < ActiveRecord::Migration
  def change
    remove_index :poll_white_results, column: [:booth_assignment_id]
    remove_index :poll_white_results, column: [:officer_assignment_id]

    drop_table :poll_white_results
  end
end
