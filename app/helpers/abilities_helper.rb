module AbilitiesHelper

  def moderator?
    current_user.try(:moderator?)
  end

end