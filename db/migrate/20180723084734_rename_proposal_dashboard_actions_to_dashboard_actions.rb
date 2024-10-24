class RenameProposalDashboardActionsToDashboardActions < ActiveRecord::Migration[4.2]
  def change
    rename_table :proposal_dashboard_actions, :dashboard_actions
    rename_column :proposal_executed_dashboard_actions, :proposal_dashboard_action_id, :dashboard_action_id
  end
end
