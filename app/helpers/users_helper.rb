module UsersHelper

  def humanize_document_type(document_type)
    case document_type
    when "1"
      t "verification.residence.new.document_type.spanish_id"
    when "2"
      t "verification.residence.new.document_type.passport"
    when "3"
      t "verification.residence.new.document_type.residence_card"
    end
  end

  def comment_commentable_title(comment)
    commentable = comment.commentable
    if commentable.nil?
      deleted_commentable_text(comment)
    elsif commentable.hidden?
      "<abbr title='#{deleted_commentable_text(comment)}'>".html_safe +
      commentable.title +
      "</abbr>".html_safe
    else
      link_to(commentable.title, comment)
    end
  end

  def deleted_commentable_text(comment)
    case comment.commentable_type
    when "Proposal"
      t("users.show.deleted_proposal")
    when "Debate"
      t("users.show.deleted_debate")
    when "Budget::Investment"
      t("users.show.deleted_budget_investment")
    else
      t("users.show.deleted")
    end
  end

  def current_administrator?
    current_user && current_user.administrator?
  end

  def interests_title_text(user)
    if current_user == user
      t('account.show.public_interests_my_title_list')
    else
      t('account.show.public_interests_user_title_list')
    end
  end

  def empty_interests_message_text(user)
    if current_user == user
      t('account.show.public_interests_my_empty_list')
    else
      t('account.show.public_interests_user_empty_list')
    end
  end

end
