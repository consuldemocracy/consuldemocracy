class RenameProposalExecutedDashboardActionsToDashboardExecutedActions < ActiveRecord::Migration
  def change
    rename_table :proposal_executed_dashboard_actions, :dashboard_executed_actions
  end
end
