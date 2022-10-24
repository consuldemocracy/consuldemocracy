class Layout::NotificationItemComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def text
      t("layouts.header.notification_item.new_notifications", count: unread_notifications.count)
    end

    def notifications_class
      if unread_notifications.count > 0
        "unread-notifications"
      else
        "no-notifications"
      end
    end

    def unread_notifications
      user.notifications.unread
    end
end
