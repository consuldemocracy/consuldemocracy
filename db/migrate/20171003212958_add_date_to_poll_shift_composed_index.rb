class AddDateToPollShiftComposedIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index "poll_shifts", column: [:booth_id, :officer_id, :task]
    remove_index "poll_shifts", :task
    add_index :poll_shifts, [:booth_id, :officer_id, :date, :task], unique: true
  end
end
