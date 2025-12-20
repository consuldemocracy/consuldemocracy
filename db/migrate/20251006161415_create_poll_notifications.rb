class CreatePollNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :polls, :notifications_sent_at, :timestamp
    add_column :users, :receive_poll_notifications, :boolean, default: false
  end
end
