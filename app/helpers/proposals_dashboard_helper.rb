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

  def request_active?(id)
    controller_name == "dashboard" && action_name == "new_request" && dashboard_action&.id == id
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
    resources.present? &&
      resources.ids.any? { |id| new_actions_since_last_login.include?(id) }
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
