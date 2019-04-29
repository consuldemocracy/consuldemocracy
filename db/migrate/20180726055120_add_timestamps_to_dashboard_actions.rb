class AddTimestampsToDashboardActions < ActiveRecord::Migration
  def change
    add_column :dashboard_actions, :created_at, :datetime
    add_column :dashboard_actions, :updated_at, :datetime
  end
end
