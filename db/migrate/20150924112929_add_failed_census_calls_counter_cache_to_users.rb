class AddFailedCensusCallsCounterCacheToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_census_calls_count, :integer, default: 0
  end
end
