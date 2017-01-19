class CreatePollRecounts < ActiveRecord::Migration
  def change
    create_table :poll_recounts do |t|
      t.integer :booth_assignment_id
      t.integer :officer_assignment_id
      t.integer :count
      t.text    :count_log, default: ""

      t.timestamps null: false
    end

    add_index :poll_recounts, :booth_assignment_id
    add_index :poll_recounts, :officer_assignment_id
  end
end
