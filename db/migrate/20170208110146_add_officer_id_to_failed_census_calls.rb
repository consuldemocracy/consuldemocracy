class AddOfficerIdToFailedCensusCalls < ActiveRecord::Migration
  def change
    add_column :failed_census_calls, :poll_officer_id, :integer, index: true
    add_foreign_key :failed_census_calls, :poll_officers
  end
end
