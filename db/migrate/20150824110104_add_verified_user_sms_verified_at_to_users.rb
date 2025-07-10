class AddVerifiedUserSmsVerifiedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :verified_user_sms_verified_at, :datetime
  end
end
