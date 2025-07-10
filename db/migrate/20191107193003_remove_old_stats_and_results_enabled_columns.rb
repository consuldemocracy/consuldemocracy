class RemoveOldStatsAndResultsEnabledColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :polls, :results_enabled, :boolean, default: false
    remove_column :polls, :stats_enabled, :boolean, default: false
  end
end
