class AddPublishedProposalToDashboardActions < ActiveRecord::Migration
  def change
    add_column :dashboard_actions, :published_proposal, :boolean, default: :false
  end
end
