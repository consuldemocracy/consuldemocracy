class AddRegisteringWithOauthToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :registering_with_oauth, :bool, default: false
  end
end
