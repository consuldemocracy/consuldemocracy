class AddPollShiftTaskIndex < ActiveRecord::Migration
  def change
    remove_index "poll_shifts", name: "index_poll_shifts_on_booth_id_and_officer_id"
    add_index :poll_shifts, :task
    add_index :poll_shifts, [:booth_id, :officer_id, :task], unique: true
  end
end
