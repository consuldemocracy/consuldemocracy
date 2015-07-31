module CommentsHelper

  def comment_link_text(parent)
    parent.class == Debate ? t("comments_helper.comment_link") : t("comments_helper.reply_link")
  end

  def comment_button_text(parent)
    parent.class == Debate ? t("comments_helper.comment_button") : t("comments_helper.reply_button")
  end

end