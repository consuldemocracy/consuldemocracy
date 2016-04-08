module ForumsHelper

  def css_for_representative(forum)
    current_user.try(:representative) == forum ? "active" : ""
  end

end