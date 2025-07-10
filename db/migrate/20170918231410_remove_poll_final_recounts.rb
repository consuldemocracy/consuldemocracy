class RemovePollFinalRecounts < ActiveRecord::Migration[4.2]
  def up
    remove_index :poll_final_recounts, column: :booth_assignment_id
    remove_index :poll_final_recounts, column: :officer_assignment_id

    remove_foreign_key :poll_final_recounts, column: "booth_assignment_id"
    remove_foreign_key :poll_final_recounts, column: "officer_assignment_id"

    drop_table :poll_final_recounts
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
