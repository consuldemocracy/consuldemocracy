class RemovePollWhiteNullTotalResults < ActiveRecord::Migration
  def change
    remove_index :poll_null_results, column: [:booth_assignment_id]
    remove_index :poll_null_results, column: [:officer_assignment_id]

    remove_index :poll_white_results, column: [:booth_assignment_id]
    remove_index :poll_white_results, column: [:officer_assignment_id]

    remove_index :poll_total_results, column: [:booth_assignment_id]
    remove_index :poll_total_results, column: [:officer_assignment_id]

    drop_table :poll_null_results
    drop_table :poll_total_results
    drop_table :poll_white_results
  end
end
