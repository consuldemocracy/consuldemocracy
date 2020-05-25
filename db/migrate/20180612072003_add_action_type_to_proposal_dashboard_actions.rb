class AddActionTypeToProposalDashboardActions < ActiveRecord::Migration[4.2]
  def change
    add_column :proposal_dashboard_actions, :action_type, :integer, null: false, default: 0
  end
end
