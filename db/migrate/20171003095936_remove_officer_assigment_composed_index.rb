class RemoveOfficerAssigmentComposedIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index "poll_officer_assignments", column: [:officer_id, :date]
  end
end
