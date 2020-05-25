module MailerHelper

  def commentable_url(commentable)
    return poll_url(commentable) if commentable.is_a?(Poll)
    return debate_url(commentable) if commentable.is_a?(Debate)
    return proposal_url(commentable) if commentable.is_a?(Proposal)
    return community_topic_url(commentable.community_id, commentable) if commentable.is_a?(Topic)
    return budget_investment_url(commentable.budget_id, commentable) if commentable.is_a?(Budget::Investment)
  end

  def valuation_comments_url(commentable)
    admin_budget_budget_investment_url(commentable.budget, commentable, anchor: "comments")
  end

  def valuation_comments_link(commentable)
    link_to(
      commentable.title,
      valuation_comments_url(@email.commentable),
      target: :blank,
      style: "color: #2895F1; text-decoration:none;"
    )
  end
end
