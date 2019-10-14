class RenameConfirmedOauthEmailToOauthEmail < ActiveRecord::Migration
  def change
    rename_column :users, :confirmed_oauth_email, :oauth_email
  end
end
