class AddAdvancedStatsToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :advanced_stats, :boolean
  end
end
