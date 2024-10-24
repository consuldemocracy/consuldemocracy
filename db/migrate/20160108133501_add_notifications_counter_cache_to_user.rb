class AddNotificationsCounterCacheToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :notifications_count, :integer, default: 0
  end
end
