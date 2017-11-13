module MailerHelper

  def commentable_url(commentable)
    return poll_url(commentable) if commentable.is_a?(Poll)
    return debate_url(commentable) if commentable.is_a?(Debate)
    return proposal_url(commentable) if commentable.is_a?(Proposal)
    return community_topic_url(commentable.community_id, commentable) if commentable.is_a?(Topic)
    return budget_investment_url(commentable.budget_id, commentable) if commentable.is_a?(Budget::Investment)
  end

end
