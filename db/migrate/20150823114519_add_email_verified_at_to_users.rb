class AddEmailVerifiedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_verified_at, :datetime
  end
end
