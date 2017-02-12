class AddFailedCensusCallsCountToPollOfficers < ActiveRecord::Migration
  def change
    add_column :poll_officers, :failed_census_calls_count, :integer, default: 0
  end
end
