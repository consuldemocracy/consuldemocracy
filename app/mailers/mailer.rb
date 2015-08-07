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
    mail(to: parent.author.email, subject: t('mailer.reply.subject'))
  end

end
