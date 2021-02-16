class Layout::NotificationItemComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def text
      if unread_notifications?
        t("layouts.header.notification_item.new_notifications", count: unread_notifications.count)
      else
        t("layouts.header.notification_item.no_notifications")
      end
    end

    def notifications_class
      if unread_notifications?
        "unread-notifications"
      else
        "no-notifications"
      end
    end

    def unread_notifications?
      unread_notifications.count > 0
    end

    def unread_notifications
      user.notifications.unread
    end
end
