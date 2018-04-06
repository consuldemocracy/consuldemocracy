class AddUserIdToLetterOfficerLogs < ActiveRecord::Migration
  def change
    add_column :poll_letter_officer_logs, :user_id, :integer
  end
end
