class Dashboard::ActiveResourceComponent < ApplicationComponent
  attr_reader :resource, :proposal, :new_actions_since_last_login
  use_helpers :is_new_action_since_last_login?

  def initialize(resource, proposal, new_actions_since_last_login)
    @resource = resource
    @proposal = proposal
    @new_actions_since_last_login = new_actions_since_last_login
  end

  def resource_card_class
    return "alert" unless resource.active_for?(proposal)
    return "success" if resource.executed_for?(proposal)

    "primary"
  end

  def resource_tooltip
    return t("dashboard.resource.resource_locked") unless resource.active_for?(proposal)
    return t("dashboard.resource.view_resource") if resource.executed_for?(proposal)
    return t("dashboard.resource.resource_requested") if resource.requested_for?(proposal)

    t("dashboard.resource.request_resource")
  end

  def resource_availability_label
    label = []

    label << t("dashboard.resource.required_days",
               days: resource.day_offset) if resource.day_offset > 0
    label << t("dashboard.resource.required_supports",
               supports: number_with_delimiter(resource.required_supports,
                                               delimiter: ".")) if resource.required_supports > 0

    safe_join label, h(" #{t("dashboard.resource.and")})") + tag(:br)
  end
end
