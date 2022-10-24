module AdminHelper
  def namespaced_root_path
    "/#{namespace}"
  end

  def namespaced_header_title
    if namespace == "moderation/budgets"
      t("moderation.header.title")
    elsif namespace == "management"
      t("management.dashboard.index.title")
    else
      t("#{namespace}.header.title")
    end
  end

  # def menu_moderated_content?
  #   moderated_sections.include?(controller_name) && controller.class.parent != Admin::Legislation
  # end

  # def moderated_sections
  #   ["hidden_proposals", "debates", "comments", "hidden_users", "activity",
  #    "hidden_budget_investments"]
  # end

  # def menu_areas?
  #   ["areas"].include?(controller_name)
  # end

  # def menu_budgets?
  #   ["budgets"].include?(controller_name)
  # end

  # def menu_budget?
  #   ["spending_proposals"].include?(controller_name)
  # end

  # def menu_polls?
  #   %w[polls questions answers recounts results].include?(controller_name)
  # end

  # def menu_booths?
  #   %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name)
  # end

  # def menu_profiles?
  #   %w[administrators organizations officials moderators valuators managers users].include?(controller_name)
  # end

  # def menu_settings?
  #   ["settings", "tags", "geozones", "images", "content_blocks"].include?(controller_name)
  # end

  # def menu_customization?
  #   ["pages", "banners", "information_texts"].include?(controller_name) || menu_homepage?
  # end

  # def menu_homepage?
  #   ["homepage", "cards"].include?(controller_name)
  # end

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
