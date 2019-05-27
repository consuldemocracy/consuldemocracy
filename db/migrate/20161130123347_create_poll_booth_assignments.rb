class CreatePollBoothAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_booth_assignments do |t|
      t.integer :booth_id
      t.integer :poll_id
      t.timestamps null: false
    end
  end
end
