module NotificationsHelper

  def notification_action(notification)
    notification.notifiable.reply? ? "replied_to_your_comment" : "commented_on_your_debate"
  end

  def notifications_class_for(user)
    user.notifications.count > 0 ? "with_notifications" : "without_notifications"
  end

end
