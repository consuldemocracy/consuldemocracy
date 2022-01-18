module ProposalsDashboardHelper
  def my_proposal_menu_active?
    controller_name == "dashboard" && action_name == "show"
  end

  def community_menu_active?
    controller_name == "dashboard" && action_name == "community"
  end

  def messages_menu_active?
    controller_name == "dashboard" && action_name == "messages"
  end

  def related_content_menu_active?
    controller_name == "dashboard" && action_name == "related_content"
  end

  def progress_menu_active?
    is_proposed_action_request? || (controller_name == "dashboard" && action_name == "progress")
  end

  def recommended_actions_menu_active?
    controller_name == "dashboard" && action_name == "recommended_actions"
  end

  def resources_menu_visible?(proposal, resources)
    can?(:manage_polls, proposal) || resources.any?
  end

  def resources_menu_active?
    poster_menu_active? || polls_menu_active? || mailing_menu_active? || is_resource_request?
  end

  def polls_menu_active?
    controller_name == "polls"
  end

  def poster_menu_active?
    controller_name == "poster"
  end

  def mailing_menu_active?
    controller_name == "mailing"
  end

  def is_resource_request?
    controller_name == "dashboard" && action_name == "new_request" && dashboard_action&.resource?
  end

  def is_proposed_action_request?
    controller_name == "dashboard" && action_name == "new_request" &&
    dashboard_action&.proposed_action?
  end

  def is_request_active(id)
    controller_name == "dashboard" && action_name == "new_request" && dashboard_action&.id == id
  end

  def resource_availability_label(resource)
    label = []

    label << t("dashboard.resource.required_days",
                days: resource.day_offset) if resource.day_offset > 0
    label << t("dashboard.resource.required_supports",
                supports: number_with_delimiter(resource.required_supports,
                delimiter: ".")) if resource.required_supports > 0

    safe_join label, h(" #{t("dashboard.resource.and")})") + tag(:br)
  end

  def daily_selected_class
    return nil if params[:group_by].blank?

    "hollow"
  end

  def weekly_selected_class
    return nil if params[:group_by] == "week"

    "hollow"
  end

  def monthly_selected_class
    return nil if params[:group_by] == "month"

    "hollow"
  end

  def resource_card_class(resource, proposal)
    return "alert" unless resource.active_for?(proposal)
    return "success" if resource.executed_for?(proposal)

    "primary"
  end

  def resource_tooltip(resource, proposal)
    return t("dashboard.resource.resource_locked") unless resource.active_for?(proposal)
    return t("dashboard.resource.view_resource") if resource.executed_for?(proposal)
    return t("dashboard.resource.resource_requested") if resource.requested_for?(proposal)

    t("dashboard.resource.request_resource")
  end

  def proposed_action_description(proposed_action)
    sanitize proposed_action.description.truncate(200)
  end

  def proposed_action_long_description?(proposed_action)
    proposed_action.description.length > 200
  end

  def is_new_action_since_last_login?(proposed_action, new_actions_since_last_login)
    if new_actions_since_last_login.present?
      new_actions_since_last_login.include?(proposed_action.id)
    end
  end

  def new_resources_since_last_login?(resources, new_actions_since_last_login)
    if resources.present?
      resources.ids.any? { |id| new_actions_since_last_login.include?(id) }
    end
  end

  def active_resources_for(proposal)
    default_resources_count = 3 #resources: mail, poster, poll
    Dashboard::Action.active.resources.active_for(proposal).count + default_resources_count
  end

  def active_resources_count(proposal)
    default_resources_count = 3 #resources: mail, poster, poll
    Dashboard::Action.active.resources.by_proposal(proposal).count + default_resources_count
  end
end
