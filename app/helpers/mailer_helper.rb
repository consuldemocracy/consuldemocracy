module MailerHelper

  def commentable_url(commentable)
    return poll_url(commentable) if commentable.is_a?(Poll)
    return debate_url(commentable) if commentable.is_a?(Debate)
    return proposal_url(commentable) if commentable.is_a?(Proposal)
    return community_topic_url(commentable.community_id, commentable) if commentable.is_a?(Topic)
    return budget_investment_url(commentable.budget_id, commentable) if commentable.is_a?(Budget::Investment)
    return spending_proposal_url(commentable) if commentable.is_a?(SpendingProposal)
    return probe_probe_option_url(commentable.probe, commentable) if commentable.is_a?(ProbeOption)
    return budget_investment_url(commentable.budget_id, commentable) if commentable.is_a?(Budget::Investment)
  end

end
