class RemoveTranslatedAttributesFromAdminNotifications < ActiveRecord::Migration
  def change
    remove_columns :admin_notifications, :title, :body
  end
end
