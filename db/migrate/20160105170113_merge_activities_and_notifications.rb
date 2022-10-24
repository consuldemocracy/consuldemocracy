class MergeActivitiesAndNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :notifications, :read, :boolean, default: false
    remove_index :notifications, column: [:activity_id]
    remove_column :notifications, :activity_id, :integer

    add_reference :notifications, :notifiable, polymorphic: true
  end
end
