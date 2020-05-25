class MergeActivitiesAndNotifications < ActiveRecord::Migration[4.2]
  def change
    change_table :notifications do |t|
      t.remove :read
      t.remove :activity_id
      t.references :notifiable, polymorphic: true
    end
  end

end
