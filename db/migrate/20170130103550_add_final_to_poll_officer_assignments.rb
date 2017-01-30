class AddFinalToPollOfficerAssignments < ActiveRecord::Migration
  def change
    add_column :poll_officer_assignments, :final, :boolean, default: false
  end
end
