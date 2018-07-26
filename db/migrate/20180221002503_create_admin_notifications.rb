class CreateAdminNotifications < ActiveRecord::Migration
  def change
    create_table :admin_notifications do |t|
      t.string :title
      t.text :body
      t.string :link
      t.string :segment_recipient
      t.integer :recipients_count
      t.date :sent_at, default: nil

      t.timestamps null: false
    end
  end
end
