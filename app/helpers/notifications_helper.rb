module NotificationsHelper

  def notification_text_for(notification)
    case notification.activity.action
    when "debate_comment"
     t("comments.notifications.commented_on_your_debate")
    when "comment_reply"
     t("comments.notifications.replied_to_your_comment")
    end
  end

  def notifications_class_for(user)
    user.notifications.unread.count > 0 ? "with_notifications" : "without_notifications"
  end

end
