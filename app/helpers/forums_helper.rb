module ForumsHelper

  def css_for_representative(forum)
    current_user.try(:representative) == forum ? "active" : ""
  end

  def forum_short_name(forum)
    forum.name.gsub("Presupuestos participativos", "")
  end

end