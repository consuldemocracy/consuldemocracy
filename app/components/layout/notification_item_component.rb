class Layout::NotificationItemComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def text
      if unread_notifications?
        t("layouts.header.notification_item.new_notifications", count: user.notifications_count)
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
      user.notifications.unread.count > 0
    end
end
