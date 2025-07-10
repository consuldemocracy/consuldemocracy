class AddConfirmedOauthEmailToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :confirmed_oauth_email, :string
  end
end
