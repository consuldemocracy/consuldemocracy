class AddShortDescriptionToProposalDashboardActions < ActiveRecord::Migration[4.2]
  def change
    add_column :proposal_dashboard_actions, :short_description, :string
    change_column :proposal_dashboard_actions, :description, :text
  end
end
