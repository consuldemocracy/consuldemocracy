class AddPublicActivityToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :public_activity, :boolean, default: true
  end
end
