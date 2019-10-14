class AddNotificationsCounterCacheToUser < ActiveRecord::Migration
  def change
    add_column :users, :notifications_count, :integer, default: 0
  end
end
