class AddDateToOfficerAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_officer_assignments, :date, :datetime
  end
end
