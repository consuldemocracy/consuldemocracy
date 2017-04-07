class AddFormerUsersDataLogToUsers < ActiveRecord::Migration
  def change
    add_column :users, :former_users_data_log, :text, default: ""
  end
end
