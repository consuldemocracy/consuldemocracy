class EmailDigest

  attr_accessor :user, :notifications

  def initialize(user)
    @user = user
  end

  def notifications
    user.notifications.not_emailed.where(notifiable_type: "ProposalNotification").to_a
  end

  def pending_notifications?
    notifications.any?
  end

  def deliver
    if pending_notifications?
      Mailer.proposal_notification_digest(user, notifications).deliver_later
    end
  end

end