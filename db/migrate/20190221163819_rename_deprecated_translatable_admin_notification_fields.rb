class RenameDeprecatedTranslatableAdminNotificationFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :admin_notifications, :title, :deprecated_title
    rename_column :admin_notifications, :body, :deprecated_body
  end
end
