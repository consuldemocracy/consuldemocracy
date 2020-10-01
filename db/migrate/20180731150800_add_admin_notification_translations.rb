class AddAdminNotificationTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :admin_notification_translations do |t|
      t.integer :admin_notification_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :body

      t.index :admin_notification_id
      t.index :locale
    end
  end
end
