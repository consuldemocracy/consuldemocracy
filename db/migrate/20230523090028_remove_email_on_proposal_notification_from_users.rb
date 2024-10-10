class RemoveEmailOnProposalNotificationFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :email_on_proposal_notification, :boolean, default: true
  end
end
