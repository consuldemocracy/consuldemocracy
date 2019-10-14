class CreatePollFinalRecount < ActiveRecord::Migration
  def change
    create_table :poll_final_recounts do |t|
      t.integer  :booth_assignment_id
      t.integer  :officer_assignment_id
      t.integer  :count
      t.text     :count_log, default: ""
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text     :officer_assignment_id_log, default: ""
    end

    add_index :poll_final_recounts, :booth_assignment_id
  end
end
