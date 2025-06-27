class Dashboard::DefaultResourceComponent < ApplicationComponent
  attr_reader :resource, :proposal
  use_helpers :can?

  def initialize(resource, proposal)
    @resource = resource
    @proposal = proposal
  end

  def render?
    can?(:"manage_#{resource}", proposal)
  end

  def resource_description
    if resource == "mailing"
      Setting["proposals.email_short_title"]
    else
      Setting["proposals.#{resource}_short_title"]
    end
  end

  def resource_path
    if resource == "polls"
      proposal_dashboard_polls_path(proposal)
    else
      send("new_proposal_dashboard_#{resource}_path", proposal)
    end
  end
end
