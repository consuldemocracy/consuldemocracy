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

  def mailer_font_family
    "font-family: 'Open Sans','Helvetica Neue',arial,sans-serif;"
  end

  def css_for_mailer_heading
    mailer_font_family + "font-size: 48px;"
  end

  def css_for_mailer_text
    mailer_font_family + "font-size: 14px;font-weight: normal;line-height: 24px;"
  end

  def css_for_mailer_button
    mailer_font_family + "background: #004a83;border-radius: 6px;color: #fff!important;display: inline-block;font-weight: bold;margin: 0;min-width: 200px;padding: 10px 15px;text-align: center;text-decoration: none;"
  end

  def css_for_mailer_link
    "color: #1779ba; text-decoration: underline;"
  end

  def css_for_mailer_quote
    "border-left: 2px solid #DEE0E3;font-style: italic;margin-left: 20px;padding: 10px;"
  end
end
