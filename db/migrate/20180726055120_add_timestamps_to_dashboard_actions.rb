class AddTimestampsToDashboardActions < ActiveRecord::Migration[4.2]
  def change
    add_column :dashboard_actions, :created_at, :datetime
    add_column :dashboard_actions, :updated_at, :datetime
  end
end
