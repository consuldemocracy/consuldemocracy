class AddPublishedProposalToDashboardActions < ActiveRecord::Migration[4.2]
  def change
    add_column :dashboard_actions, :published_proposal, :boolean, default: false
  end
end
