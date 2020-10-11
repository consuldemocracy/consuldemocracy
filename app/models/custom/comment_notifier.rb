require_dependency Rails.root.join("app", "models", "comment_notifier").to_s

class CommentNotifier
  def process
    send_comment_email_to_officials
    send_comment_email
    send_reply_email
  end

  private
    def send_comment_email_to_officials
      if @comment.commentable.is_a?(Taggable)
        @project = @comment.commentable.tag_list_with_limit(1)
        if !@project.empty?
          @officials_by_project = User.officials_by_project(@project.first)
          @officials_by_project.each do |official|
            Mailer.commentForOfficial(@comment, official).deliver_later
          end
        end
      end
    end
end
