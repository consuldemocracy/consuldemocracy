class AddEmailOnProposalNotificationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_on_proposal_notification, :boolean, default: true
  end
end
