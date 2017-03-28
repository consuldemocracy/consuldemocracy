class AddCensusNameAndCensusPostalCodeToLetterOfficerLog < ActiveRecord::Migration
  def change
    add_column :poll_letter_officer_logs, :census_name, :string
    add_column :poll_letter_officer_logs, :census_postal_code, :string
  end
end
