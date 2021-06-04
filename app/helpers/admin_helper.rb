module AdminHelper
  def namespaced_root_path
    "/#{namespace}"
  end

  def namespaced_header_title
    if namespace == "moderation/budgets"
      t("moderation.header.title")
    else
      t("#{namespace}.header.title")
    end
  end

  def official_level_options
    options = [["", 0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), setting["official_level_#{i}_name"]].compact.join(": "), i]
    end
    options
  end

  def admin_submit_action(resource)
    resource.persisted? ? "edit" : "new"
  end

  def user_roles(user)
    roles = []
    roles << :admin if user.administrator?
    roles << :moderator if user.moderator?
    roles << :valuator if user.valuator?
    roles << :manager if user.manager?
    roles << :poll_officer if user.poll_officer?
    roles << :official if user.official?
    roles << :organization if user.organization?
    roles
  end

  def display_user_roles(user)
    user_roles(user).join(", ")
  end

  def namespace
    controller.class.name.split("::").first.underscore
  end
end
