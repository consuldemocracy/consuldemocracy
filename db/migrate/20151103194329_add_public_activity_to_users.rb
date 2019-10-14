class AddPublicActivityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_activity, :boolean, default: true
  end
end
