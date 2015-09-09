class SetUsernameLimit < ActiveRecord::Migration
  def change
    change_column :users, :username, :string, limit: 200
  end
end
