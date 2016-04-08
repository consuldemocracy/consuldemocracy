class AddAcceptedDelegationAlertToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accepted_delegation_alert, :boolean, default: false
  end
end
