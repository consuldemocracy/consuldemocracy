class AddPreferencesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_debate_comment, :boolean, default: false
    add_column :users, :email_on_comment_reply, :boolean, default: false
  end
end
