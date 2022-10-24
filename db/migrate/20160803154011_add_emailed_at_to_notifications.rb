class AddEmailedAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :emailed_at, :datetime
  end
end
