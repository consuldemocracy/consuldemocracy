class RemovePollRecount < ActiveRecord::Migration[4.2]
  def up
    remove_index :poll_recounts, column: [:booth_assignment_id]
    remove_index :poll_recounts, column: [:officer_assignment_id]

    drop_table :poll_recounts
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
