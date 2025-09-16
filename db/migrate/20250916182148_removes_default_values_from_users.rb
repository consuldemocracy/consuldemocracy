class RemovesDefaultValuesFromUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:users, :newsletter, false)
    change_column_default(:users, :email_digest, false)
    change_column_default(:users, :email_on_direct_message, false)
  end
end
