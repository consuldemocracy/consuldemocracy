require_dependency Rails.root.join('app', 'helpers', 'admin_helper').to_s

module Custom::AdminHelper

  def menu_profiles?
    %w[administrators organizations officials moderators valuators managers users activity animators].include?(controller_name)
  end

  def user_roles(user)
    roles = []
    roles << translated_role(:admin) if user.administrator?
    roles << translated_role(:moderator) if user.moderator?
    roles << translated_role(:valuator) if user.valuator?
    roles << translated_role(:manager) if user.manager?
    roles << translated_role(:poll_officer) if user.poll_officer?
    roles << translated_role(:official) if user.official?
    roles << translated_role(:organization) if user.organization?
    roles << translated_role(:animator) if user.animator?
    roles
  end

  def display_user_roles(user)
    user_roles(user).join(", ")
  end

  def translated_role(role)
    # I18n.t(role, scope: [:activerecord, :models])
    I18n.t("activerecord.models.#{role}.one")
  end

end