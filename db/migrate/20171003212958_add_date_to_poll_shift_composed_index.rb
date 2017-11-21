class AddDateToPollShiftComposedIndex < ActiveRecord::Migration
  def change
    remove_index "poll_shifts", name: "index_poll_shifts_on_booth_id_and_officer_id_and_task"
    remove_index "poll_shifts", name: "index_poll_shifts_on_task"
    add_index :poll_shifts, [:booth_id, :officer_id, :date, :task], unique: true
  end
end
