class AddRegisteringWithOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registering_with_oauth, :bool, default: false
  end
end
