module CommentsHelper

  def comment_link_text(parent_id)
    parent_id.present? ? t("comments_helper.reply_link") : t("comments_helper.comment_link")
  end

  def comment_button_text(parent_id)
    parent_id.present?  ? t("comments_helper.reply_button") : t("comments_helper.comment_button")
  end

end