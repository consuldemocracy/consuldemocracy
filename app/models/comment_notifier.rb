class CommentNotifier
  def initialize(args = {})
    @comment = args.fetch(:comment)
    @author  = @comment.author
  end

  def process
    send_comment_email
    send_reply_email
  end

  private

    def send_comment_email
      if !@comment.commentable.is_a?(Legislation::Annotation) && email_on_comment?
        Mailer.comment(@comment).deliver_later
      end
    end

    def send_reply_email
      Mailer.reply(@comment).deliver_later if email_on_comment_reply?
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
