class Mailer < ApplicationMailer

  def comment(comment)
    @comment = comment
    @debate = comment.debate
    mail(to: @debate.author.email, subject: t('mailer.comment.subject'))
  end

  def reply(reply)
    @reply = reply
    @debate = @reply.debate
    parent = Comment.find(@reply.parent_id)
    @recipient = parent.author
    mail(to: @recipient.email, subject: t('mailer.reply.subject'))
  end

  def email_verification(user, recipient, token)
    @user = user
    @recipient = recipient
    @token = token
    mail(to: @recipient, subject: "Verifica tu email")
  end

end
