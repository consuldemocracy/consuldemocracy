module UsersHelper

  def comment_commentable_title(comment)
    commentable = comment.commentable
    if commentable.nil?
      deleted_commentable_text(comment)
    elsif commentable.hidden?
      "<abbr title='#{deleted_commentable_text(comment)}'>".html_safe +
      commentable.title +
      "</abbr>".html_safe
    else
      link_to(commentable.title, commentable)
    end
  end

  def deleted_commentable_text(comment)
    case comment.commentable_type
    when "Proposal"
      t("users.show.deleted_proposal")
    when "Debate"
      t("users.show.deleted_debate")
    else
      t("users.show.deleted")
    end
  end

end