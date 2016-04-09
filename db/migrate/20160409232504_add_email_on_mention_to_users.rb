class AddEmailOnMentionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_mention, :boolean, default: false
  end
end
