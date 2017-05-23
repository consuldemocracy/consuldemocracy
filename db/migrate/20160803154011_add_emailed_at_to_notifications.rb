class AddEmailedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :emailed_at, :datetime
  end
end
