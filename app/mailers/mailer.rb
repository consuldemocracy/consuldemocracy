class Mailer < ApplicationMailer
  helper :text_with_links
  helper :mailer

  def comment(comment)
    @comment = comment
    @commentable = comment.commentable
    mail(to: @commentable.author.email, subject: t('mailers.comment.subject', commentable: t("activerecord.models.#{@commentable.class.name.downcase}", count: 1).downcase)) if @commentable.present? && @commentable.author.present?
  end

  def reply(reply)
    @reply = reply
    @commentable = @reply.commentable
    parent = Comment.find(@reply.parent_id)
    @recipient = parent.author
    mail(to: @recipient.email, subject: t('mailers.reply.subject')) if @commentable.present? && @recipient.present?
  end

  def email_verification(user, recipient, token)
    @user = user
    @recipient = recipient
    @token = token
    mail(to: @recipient, subject: t('mailers.email_verification.subject'))
  end

end
