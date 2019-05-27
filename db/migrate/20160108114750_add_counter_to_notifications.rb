class AddCounterToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :counter, :integer, default: 1
  end
end
