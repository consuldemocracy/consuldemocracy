class AddTimestampsToDashboardActions < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :dashboard_actions
  end
end
