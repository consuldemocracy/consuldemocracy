class AddDateToOfficerAssignment < ActiveRecord::Migration
  def change
    add_column :poll_officer_assignments, :date, :datetime
  end
end
