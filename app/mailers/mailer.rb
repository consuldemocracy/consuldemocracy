class Mailer < ApplicationMailer
  helper :text_with_links
  helper :mailer
  helper :users

  def comment(comment)
    @comment = comment
    @commentable = comment.commentable
    with_user(@commentable.author) do
      mail(to: @commentable.author.email, subject: t('mailers.comment.subject', commentable: t("activerecord.models.#{@commentable.class.name.underscore}", count: 1).downcase)) if @commentable.present? && @commentable.author.present?
    end
  end

  def reply(reply)
    @reply = reply
    @commentable = @reply.commentable
    parent = Comment.find(@reply.parent_id)
    @recipient = parent.author
    with_user(@recipient) do
      mail(to: @recipient.email, subject: t('mailers.reply.subject')) if @commentable.present? && @recipient.present?
    end
  end

  def email_verification(user, recipient, token, document_type, document_number)
    @user = user
    @recipient = recipient
    @token = token
    @document_type = document_type
    @document_number = document_number

    with_user(user) do
      mail(to: @recipient, subject: t('mailers.email_verification.subject'))
    end
  end

  def unfeasible_spending_proposal(spending_proposal)
    @spending_proposal = spending_proposal
    @author = spending_proposal.author

    with_user(@author) do
      mail(to: @author.email, subject: t('mailers.unfeasible_spending_proposal.subject', code: @spending_proposal.code))
    end
  end

  def direct_message_for_receiver(direct_message)
    @direct_message = direct_message
    @receiver = @direct_message.receiver

    with_user(@receiver) do
      mail(to: @receiver.email, subject: t('mailers.direct_message_for_receiver.subject'))
    end
  end

  def direct_message_for_sender(direct_message)
    @direct_message = direct_message
    @sender = @direct_message.sender

    with_user(@sender) do
      mail(to: @sender.email, subject: t('mailers.direct_message_for_sender.subject'))
    end
  end

  def proposal_notification_digest(user, notifications)
    @notifications = notifications

    with_user(user) do
      mail(to: user.email, subject: t('mailers.proposal_notification_digest.title', org_name: Setting['org_name']))
    end
  end

  def user_invite(email)
    I18n.with_locale(I18n.default_locale) do
      mail(to: email, subject: t('mailers.user_invite.subject', org_name: Setting["org_name"]))
    end
  end

  def budget_investment_created(investment)
    @investment = investment

    with_user(@investment.author) do
      mail(to: @investment.author.email, subject: t('mailers.budget_investment_created.subject'))
    end
  end

  def budget_investment_unfeasible(investment)
    @investment = investment
    @author = investment.author

    with_user(@author) do
      mail(to: @author.email, subject: t('mailers.budget_investment_unfeasible.subject', code: @investment.code))
    end
  end

  private

  def with_user(user, &block)
    I18n.with_locale(user.locale) do
      block.call
    end
  end
end
