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


  def deliver(run_at)
    if valid_email? && pending_notifications?
      Mailer.delay(run_at: run_at).proposal_notification_digest(user, notifications.to_a)
      mark_as_emailed
    end
  end

  def mark_as_emailed
    notifications.update_all(emailed_at: Time.current)
    user.update(failed_email_digests_count: 0)
  end

  def valid_email?
    user.email.present? && user.email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
  end

end
