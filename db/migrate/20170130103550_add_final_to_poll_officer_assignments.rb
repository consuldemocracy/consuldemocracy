class AddFinalToPollOfficerAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_officer_assignments, :final, :boolean, default: false
  end
end
