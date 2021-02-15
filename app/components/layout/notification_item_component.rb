class Layout::NotificationItemComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def text
      if user.notifications.unread.count > 0
        t("layouts.header.notification_item.new_notifications", count: user.notifications_count)
      else
        t("layouts.header.notification_item.no_notifications")
      end
    end
end
