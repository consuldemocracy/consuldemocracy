class Comments::CommentComponent < ApplicationComponent
  attr_reader :comment, :valuation
  delegate :current_order, :locale_and_user_status, :commentable_cache_key, :sanitize_and_auto_link,
           to: :helpers

  def initialize(comment, valuation: false)
    @comment = comment
    @valuation = valuation
  end

  private

    def child_comments
      if current_order
        comment.children.send("sort_descendants_by_#{current_order}")
      else
        comment.children
      end
    end

    def user_level_class
      if comment.as_administrator?
        "is-admin"
      elsif comment.as_moderator?
        "is-moderator"
      elsif comment.user.official?
        "level-#{comment.user.official_level}"
      else
        ""
      end
    end

    def comment_author_class
      if comment.user_id == comment.commentable.author_id
        "is-author"
      else
        ""
      end
    end
end
