class RemovePollTotalResult < ActiveRecord::Migration
  def change
    remove_index :poll_total_results, column: [:booth_assignment_id]
    remove_index :poll_total_results, column: [:officer_assignment_id]

    drop_table :poll_total_results
  end
end
