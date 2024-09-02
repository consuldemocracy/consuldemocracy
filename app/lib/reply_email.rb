class ReplyEmail
  attr_reader :reply

  def initialize(reply)
    @reply = reply
  end

  def commentable
    reply.commentable
  end

  def recipient
    reply.parent.author
  end

  def to
    recipient.email
  end

  def subject
    I18n.t("mailers.reply.subject")
  end

  def can_be_sent?
    commentable.present? && recipient.present?
  end
end
