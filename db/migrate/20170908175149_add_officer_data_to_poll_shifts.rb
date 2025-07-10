class AddOfficerDataToPollShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_shifts, :officer_name, :string
    add_column :poll_shifts, :officer_email, :string
  end
end
