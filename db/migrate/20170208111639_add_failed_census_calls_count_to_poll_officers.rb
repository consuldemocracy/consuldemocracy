class AddFailedCensusCallsCountToPollOfficers < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_officers, :failed_census_calls_count, :integer, default: 0
  end
end
