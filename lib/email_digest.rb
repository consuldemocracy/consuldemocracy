class EmailDigest

  attr_accessor :user, :notifications

  def initialize(user)
    @user = user
  end

  def notifications
    user.notifications.not_emailed.where(notifiable_type: "ProposalNotification")
  end

  def pending_notifications?
    notifications.any?
  end

  def deliver
    if pending_notifications?
      Mailer.proposal_notification_digest(user, notifications.to_a).deliver_later
    end
  end

  def mark_as_emailed
    notifications.update_all(emailed_at: Time.current)
    user.update(failed_email_digests_count: 0)
  end

end
