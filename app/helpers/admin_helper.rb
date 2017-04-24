module AdminHelper

  def side_menu
    render "/#{namespace}/menu"
  end

  def namespaced_root_path
    "/#{namespace}"
  end

  def namespaced_header_title
    t("#{namespace}.header.title")
  end

  def menu_tags?
    ["tags"].include? controller_name
  end

  def menu_moderated_content?
    ["proposals", "debates", "comments", "users"].include? controller_name
  end

  def menu_budget?
    ["spending_proposals"].include? controller_name
  end

  def menu_polls?
    ["polls", "questions", "officers", "booths", "officer_assignments", "booth_assignments", "recounts", "results"].include? controller_name
  end

  def menu_profiles?
    ["organizations", "officials", "moderators", "valuators", "managers"].include? controller_name
  end

  def menu_banners?
    ["banners"].include? controller_name
  end

  def official_level_options
    options = [["", 0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), setting["official_level_#{i}_name"]].compact.join(': '), i]
    end
    options
  end

  def admin_select_options
    Administrator.all.order('users.username asc').includes(:user).collect { |v| [ v.name, v.id ] }
  end

  def admin_submit_action(resource)
    resource.persisted? ? "edit" : "new"
  end

  private

    def namespace
      controller.class.parent.name.downcase.gsub("::", "/")
    end

end
