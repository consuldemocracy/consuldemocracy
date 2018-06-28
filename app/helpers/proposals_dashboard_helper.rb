module ProposalsDashboardHelper
  def resources_menu_visible?(proposal, resources)
    can?(:manage_polls, proposal) || resources.any?
  end

  def progress_menu(&block)
    menu_group('progress-menu', progress_menu_active?, &block)
  end

  def progress_menu_active?
    actions_menu_active? || stats_menu_active?
  end

  def actions_menu(&block)
    menu_entry(actions_menu_active?, &block)
  end

  def actions_menu_active?
    (controller_name == 'proposals_dashboard' && action_name == 'index') || is_proposed_action_request?
  end

  def stats_menu(&block)
    menu_entry(stats_menu_active?, &block)
  end

  def stats_menu_active?
    controller_name == 'proposals_dashboard' && action_name == 'stats'
  end

  def resources_menu(&block)
    menu_group('resources-menu', resources_menu_active?, &block)
  end

  def polls_menu(&block)
    menu_entry(polls_menu_active?, &block)
  end

  def resources_menu_active?
    polls_menu_active? || is_resource_request? 
  end

  def polls_menu_active?
    controller_name == 'polls'
  end

  def menu_group(id, active, &block)
    html_class = nil
    html_class = 'is-active' if active

    content_tag(:ul, id: id, class: html_class) do
      yield
    end
  end

  def menu_entry(active, &block)
    content = capture(&block)
    html_class = nil
    html_class = 'is-active' if active

    content_tag(:li, content, class: html_class)
  end

  def is_resource_request?
    controller_name == 'proposals_dashboard' && action_name == 'new_request' && proposal_dashboard_action&.resource?
  end

  def is_proposed_action_request?
    controller_name == 'proposals_dashboard' && action_name == 'new_request' && proposal_dashboard_action&.proposed_action?
  end

  def is_request_active(id)
    controller_name == 'proposals_dashboard' && action_name == 'new_request' && proposal_dashboard_action&.id == id
  end
end
