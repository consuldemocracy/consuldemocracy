class AddFailedCensusCallsCounterCacheToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :failed_census_calls_count, :integer, default: 0
  end
end
