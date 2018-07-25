class RenameDashboardActionIdToActionId < ActiveRecord::Migration
  def change
    rename_column :dashboard_executed_actions, :dashboard_action_id, :action_id 
  end
end
