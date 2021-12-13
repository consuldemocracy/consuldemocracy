module MailerHelper
  def commentable_url(commentable)
    polymorphic_url(commentable)
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
