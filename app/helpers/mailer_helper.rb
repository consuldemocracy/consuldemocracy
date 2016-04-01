module MailerHelper

  def commentable_url(commentable)
    return debate_url(commentable) if commentable.is_a?(Debate)
    return proposal_url(commentable) if commentable.is_a?(Proposal)
    return spending_proposal_url(commentable) if commentable.is_a?(SpendingProposal)
  end

end