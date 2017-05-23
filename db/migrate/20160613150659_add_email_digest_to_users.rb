class AddEmailDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_digest, :boolean, default: true
  end
end
