module CommentsHelper

  def comment_tree_title_text(commentable)
    if commentable.class == Legislation::Question
      t("legislation.questions.comments.comments_title")
    else
      t("comments_helper.comments_title")
    end
  end

  def leave_comment_text(commentable)
    if commentable.class == Legislation::Question
      t("legislation.questions.comments.form.leave_comment")
    else
      t("comments.form.leave_comment")
    end
  end

  def comment_link_text(parent_id)
    parent_id.present? ? t("comments_helper.reply_link") : t("comments_helper.comment_link")
  end

  def comment_button_text(parent_id, commentable)
    if commentable.class == Legislation::Question
      parent_id.present? ? t("comments_helper.reply_button") : t("legislation.questions.comments.comment_button")
    else
      parent_id.present? ? t("comments_helper.reply_button") : t("comments_helper.comment_button")
    end
  end

  def parent_or_commentable_dom_id(parent_id, commentable)
    parent_id.blank? ? dom_id(commentable) : "comment_#{parent_id}"
  end

  def child_comments_of(parent)
    if @comment_tree.present?
      @comment_tree.ordered_children_of(parent)
    else
      parent.children
    end
  end

  def commentable_path(comment)
    polymorphic_hierarchy_path(comment.commentable)
  end

  def user_level_class(comment)
    if comment.as_administrator?
      "is-admin"
    elsif comment.as_moderator?
      "is-moderator"
    elsif comment.user.official?
      "level-#{comment.user.official_level}"
    else
      "" # Default no special user class
    end
  end

  def comment_author_class(comment, author_id)
    if comment.user_id == author_id
      "is-author"
    else
      "" # Default not author class
    end
  end

  def require_verified_resident_for_commentable?(commentable, current_user)
    return false if current_user.administrator? || current_user.moderator?

    commentable.respond_to?(:comments_for_verified_residents_only?) &&
      commentable.comments_for_verified_residents_only? &&
      !current_user.residence_verified?
  end

  def comments_closed_for_commentable?(commentable)
    commentable.respond_to?(:comments_closed?) && commentable.comments_closed?
  end

  def comments_closed_text(commentable)
    if commentable.class == Legislation::Question
      t("legislation.questions.comments.comments_closed")
    else
      t("comments.comments_closed")
    end
  end

end
