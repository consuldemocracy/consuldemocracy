class AddShortDescriptionToProposalDashboardActions < ActiveRecord::Migration[4.2]
  def up
    add_column :proposal_dashboard_actions, :short_description, :string
    change_column :proposal_dashboard_actions, :description, :text
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
