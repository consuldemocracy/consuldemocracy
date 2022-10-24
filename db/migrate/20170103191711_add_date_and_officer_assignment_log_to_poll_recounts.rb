class AddDateAndOfficerAssignmentLogToPollRecounts < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_recounts, :date, :datetime
    add_column :poll_recounts, :officer_assignment_id_log, :text, default: ""
  end
end
