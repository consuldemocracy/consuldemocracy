class RemoveDeprecatedTranslatableFieldsFromAdminNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :admin_notifications, :title, :string
    remove_column :admin_notifications, :body, :text
  end
end
