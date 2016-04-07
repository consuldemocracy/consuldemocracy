module ForumsHelper

  def css_for_representative(forum)
    current_user.representative == forum ? "active" : ""
  end

end