class CommentNotifier
  def initialize(args = {})
    @comment = args.fetch(:comment)
    @author  = @comment.author
  end

  def process
    send_comment_email
    send_reply_email
    send_mention_emails
  end

  private

  def send_comment_email
    Mailer.comment(@comment).deliver_later if email_on_comment?
  end

  def send_reply_email
    Mailer.reply(@comment).deliver_later if email_on_comment_reply?
  end

  def send_mention_emails
    m = CommentMentionProcessor.new
    m.add_before_callback Proc.new { |post, user| user != @author }
    m.add_after_callback Proc.new { |post, user| Mailer.mention(post, user).deliver_later }
    m.process_mentions(@comment)
  end

  def email_on_comment?
    commentable_author = @comment.commentable.author
    commentable_author != @author && commentable_author.email_on_comment?
  end

  def email_on_comment_reply?
    return false unless @comment.reply?
    parent_author = @comment.parent.author
    parent_author != @author && parent_author.email_on_comment_reply?
  end

end
