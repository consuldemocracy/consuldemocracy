class AddConfirmedOauthEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :confirmed_oauth_email, :string
  end
end
