class CreatePollRecount < ActiveRecord::Migration
  def change
    create_table :poll_recounts do |t|
      t.integer :author_id
      t.string  :origin
      t.date    :date
      t.integer :booth_assignment_id
      t.integer :officer_assignment_id
      t.text    :officer_assignment_id_log,       default: ""
      t.text    :author_id_log,                   default: ""
      t.integer :white_amount
      t.text    :white_amount_log,                default: ""
      t.integer :null_amount
      t.text    :null_amount_log,                 default: ""
      t.integer :total_amount
      t.text    :total_amount_log,                default: ""
    end

    add_index :poll_recounts, :booth_assignment_id
    add_index :poll_recounts, :officer_assignment_id
    add_foreign_key :poll_recounts, :poll_booth_assignments,   column: :booth_assignment_id
    add_foreign_key :poll_recounts, :poll_officer_assignments, column: :officer_assignment_id
  end
end
