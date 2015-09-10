class SetUsernameLimit < ActiveRecord::Migration
  def change
    execute "ALTER TABLE users ALTER COLUMN username TYPE VARCHAR(60) USING SUBSTR(username, 1, 60)"
    change_column :users, :username, :string, limit: 60
  end
end
