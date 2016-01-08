module NotificationsHelper

  def notification_action(notification)
    notification.notifiable.reply? ? "replied_to_your_comment" : "commented_on_your_debate"
  end
end
