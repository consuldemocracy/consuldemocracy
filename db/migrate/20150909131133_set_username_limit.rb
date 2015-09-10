class SetUsernameLimit < ActiveRecord::Migration
  def change
    change_column :users, :username, :string, limit: 60
  end
end
