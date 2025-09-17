class RemovesDefaultValuesFromUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:users, :newsletter, from: true, to: false)
    change_column_default(:users, :email_digest, from: true, to: false)
    change_column_default(:users, :email_on_direct_message, from: true, to: false)
  end
end
