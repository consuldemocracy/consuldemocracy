class AddShortDescriptionToProposalDashboardActions < ActiveRecord::Migration
  def change
    add_column :proposal_dashboard_actions, :short_description, :string
    change_column :proposal_dashboard_actions, :description, :text
  end
end
