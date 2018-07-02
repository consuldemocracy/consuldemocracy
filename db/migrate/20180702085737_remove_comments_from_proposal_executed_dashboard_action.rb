class RemoveCommentsFromProposalExecutedDashboardAction < ActiveRecord::Migration
  def change
    remove_column :proposal_executed_dashboard_actions, :comments, :text
  end
end
