class Mailer < ApplicationMailer
  helper :text_with_links
  helper :mailer
  helper :users

  def comment(comment)
    @comment = comment
    @commentable = comment.commentable
    with_user(@commentable.author) do
      mail(to: @commentable.author.email, subject: t('mailers.comment.subject', commentable: t("activerecord.models.#{@commentable.class.name.downcase}", count: 1).downcase)) if @commentable.present? && @commentable.author.present?
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

  private

  def with_user(user, &block)
    I18n.with_locale(user.locale) do
      block.call
    end
  end
end
