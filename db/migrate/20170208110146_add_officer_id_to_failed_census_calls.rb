class AddOfficerIdToFailedCensusCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :failed_census_calls, :poll_officer_id, :integer
    add_foreign_key :failed_census_calls, :poll_officers
  end
end
