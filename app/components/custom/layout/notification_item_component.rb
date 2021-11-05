class Layout::NotificationItemComponent < ApplicationComponent; end
require_dependency Rails.root.join("app", "components", "layout", "notification_item_component").to_s
class Layout::NotificationItemComponent
  # Your custom logic here

  private

    def notification_count
      unread_notifications.count
    end

    def notification_badge_class
      if unread_notifications.count > 0
        "visible"
      else
        "invisible"
      end
    end
  end
