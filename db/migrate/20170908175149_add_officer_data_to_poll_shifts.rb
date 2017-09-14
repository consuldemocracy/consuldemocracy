class AddOfficerDataToPollShifts < ActiveRecord::Migration
  def change
    add_column :poll_shifts, :officer_name, :string
    add_column :poll_shifts, :officer_email, :string
  end
end
