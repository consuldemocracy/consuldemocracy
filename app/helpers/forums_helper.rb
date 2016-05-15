module ForumsHelper

  def css_for_representative(forum)
    current_user.try(:representative) == forum ? "active" : ""
  end

  def forum_short_name(forum)
    forum.name.gsub("Presupuestos participativos", "")
  end

  def forum_confirm_data(forum)
    ballot = @current_user.ballot
    if ballot.present? && ballot.ballot_lines.count > 0
      { confirm: t("forums.show.confirm", forum: forum.name) }
    end
  end

end
