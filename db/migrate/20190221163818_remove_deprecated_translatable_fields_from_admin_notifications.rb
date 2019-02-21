class RemoveDeprecatedTranslatableFieldsFromAdminNotifications < ActiveRecord::Migration
  def change
    remove_column :admin_notifications, :title, :string
    remove_column :admin_notifications, :body, :text
  end
end
