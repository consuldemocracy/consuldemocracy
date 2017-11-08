class AddPostalCodeToPollLetterOfficingLog < ActiveRecord::Migration
  def change
    add_column :poll_letter_officer_logs, :postal_code, :string
  end
end
