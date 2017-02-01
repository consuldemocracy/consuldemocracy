module QuestionsHelper

  def comment_kind_select_options
    ['comment', 'question'].collect do |comment_kind|
      [t("comment_kinds.#{comment_kind}"), comment_kind]
    end
  end

  def comment_count(resource)
    comment_kind = find_comment_kind(resource)
    t("debates.show.#{comment_kind.pluralize}", count: resource.comments_count)
  end

  def comment_title
    t("debates.show.#{@debate.comment_kind.pluralize}_title")
  end

  def comment_label(css_id, parent_id, commentable)
    comment_kind = find_comment_kind(commentable)
    if parent_id.present?
      comment_label_for_reply
    else
      t("#{comment_kind.pluralize}.form.leave_comment")
    end
  end

  def comment_label_for_reply
    t("comments.form.leave_reply")
  end

  def find_comment_kind(resource)
    comment_kind = 'comment'
    if resource.present? && resource.is_a?(Debate)
      comment_kind = resource.comment_kind
    end
    return comment_kind
  end

end
