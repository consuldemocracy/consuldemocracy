class EmailDigest

  def initialize
  end

  def create
    User.email_digest.each do |user|
      if user.notifications.where(notifiable_type: "ProposalNotification").any?
        top_proposal = Proposal.find(9)
        if user.voted_for?(top_proposal)
          Mailer.proposal_notification_digest(user).deliver_later
        end
      end
    end
  end

end