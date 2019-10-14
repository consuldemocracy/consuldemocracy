class AddEmailOnDirectMessagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_direct_message, :boolean, default: true
  end
end
