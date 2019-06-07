class AddModerationFlagsToProposalNotifications < ActiveRecord::Migration
  def change
    add_column :proposal_notifications, :moderated, :boolean, default: false
    add_column :proposal_notifications, :hidden_at, :datetime
    add_column :proposal_notifications, :ignored_at, :datetime
    add_column :proposal_notifications, :confirmed_hide_at, :datetime
  end
end
