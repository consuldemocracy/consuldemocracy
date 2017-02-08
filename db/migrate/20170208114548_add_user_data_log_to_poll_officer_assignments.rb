class AddUserDataLogToPollOfficerAssignments < ActiveRecord::Migration
  def change
    add_column :poll_officer_assignments, :user_data_log, :string, default: ""
  end
end
