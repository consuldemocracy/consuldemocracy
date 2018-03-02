class AddTimestampsToPollLetterOfficerLogs < ActiveRecord::Migration
  def change
    add_timestamps :poll_letter_officer_logs
  end
end
