class AddCounterToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :counter, :integer, default: 1
  end
end
