class AddEmailDigestToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_digest, :boolean, default: true
  end
end
