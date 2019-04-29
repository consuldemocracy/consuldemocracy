class RemoveCommentsFromProposalExecutedDashboardAction < ActiveRecord::Migration[4.2]
  def change
    remove_column :proposal_executed_dashboard_actions, :comments, :text
  end
end
