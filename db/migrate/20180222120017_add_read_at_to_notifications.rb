class AddReadAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :read_at, :timestamp
  end
end
