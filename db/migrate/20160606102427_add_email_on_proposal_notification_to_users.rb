class AddEmailOnProposalNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_proposal_notification, :boolean, default: true
  end
end
