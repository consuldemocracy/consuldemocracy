class AddEmailVerifiedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_verified_at, :datetime
  end
end
