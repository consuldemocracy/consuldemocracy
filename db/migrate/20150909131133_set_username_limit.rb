class SetUsernameLimit < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE users ALTER COLUMN username TYPE VARCHAR(60) USING SUBSTR(username, 1, 60)"
    change_column :users, :username, :string, limit: 60
  end

  def down
    change_column :users, :username, :string, limit: nil
  end
end
