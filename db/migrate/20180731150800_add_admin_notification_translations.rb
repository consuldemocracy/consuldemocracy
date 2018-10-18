class AddAdminNotificationTranslations < ActiveRecord::Migration

  def self.up
    AdminNotification.create_translation_table!(
      title: :string,
      body:  :text
    )
  end

  def self.down
    AdminNotification.drop_translation_table!
  end
end

