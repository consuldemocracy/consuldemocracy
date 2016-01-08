module NotificationsHelper

  def notification_action(notification)
    notification.notifiable_type == "Comment" ? "replies_to" : "comments_on"
  end
end
