class RenameDashboardActionIdToActionId < ActiveRecord::Migration[4.2]
  def change
    rename_column :dashboard_executed_actions, :dashboard_action_id, :action_id
  end
end
