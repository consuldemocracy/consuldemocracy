module NotificationsHelper

  def notification_text_for(notification)
    if notification.notifiable.reply?
      t("comments.notifications.replied_to_your_comment")
    else
      t("comments.notifications.commented_on_your_debate")
    end
  end

  def notifications_class_for(user)
    user.notifications.count > 0 ? "with_notifications" : "without_notifications"
  end

end
