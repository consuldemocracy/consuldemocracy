class RenameConfirmedOauthEmailToOauthEmail < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :confirmed_oauth_email, :oauth_email
  end
end
