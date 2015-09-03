module CommentsHelper

  def comment_link_text(parent_id)
    parent_id.present? ? t("comments_helper.reply_link") : t("comments_helper.comment_link")
  end

  def comment_button_text(parent_id)
    parent_id.present?  ? t("comments_helper.reply_button") : t("comments_helper.comment_button")
  end

  def parent_or_commentable_dom_id(parent_id, commentable)
    parent_id.blank? ? dom_id(commentable) : "comment_#{parent_id}"
  end

  def select_children(comments, parent)
    return [] if comments.blank?
    comments.select{|c| c.parent_id == parent.id}
  end

end