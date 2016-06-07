module NotificationsHelper

  def notification_action(notification)
    case notification.notifiable_type
    when "ProposalNotification"
      "proposal_notification"
    when "Comment"
      "replies_to"
    else
      "comments_on"
    end
  end
end
