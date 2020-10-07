class CommentNotifier
  def initialize(args = {})
    @comment = args.fetch(:comment)
    @author  = @comment.author
  end

  def process
    send_comment_email_to_officials
    send_comment_email
    send_reply_email
  end

  private

    def send_comment_email
      unless @comment.commentable.is_a?(Legislation::Annotation)
        Mailer.comment(@comment).deliver_later if email_on_comment?
      end
    end

    def send_reply_email
      Mailer.reply(@comment).deliver_later if email_on_comment_reply?
    end
    
    def send_comment_email_to_officials
      @project = @comment.commentable.tag_list_with_limit(1)
      if !@project.empty?
        @officials_by_project = User.officials_by_project(@project.first)
        @officials_by_project.each do |official|
          Mailer.commentForOfficial(@comment, official).deliver_later
        end
      end
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
