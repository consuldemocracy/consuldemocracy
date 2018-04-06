class AddLetterOfficerToPollOfficers < ActiveRecord::Migration
  def change
    add_column :poll_officers, :letter_officer, :boolean, default: false
  end
end
