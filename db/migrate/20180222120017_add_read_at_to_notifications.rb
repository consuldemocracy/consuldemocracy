class AddReadAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :read_at, :timestamp
  end
end
