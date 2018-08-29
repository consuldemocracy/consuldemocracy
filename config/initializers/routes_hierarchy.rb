# This module is expanded in order to make it easier to use polymorphic
# routes with nested resources.
# HACK: is there a way to avoid monkey-patching here? Using helpers is
# a similar use of a global namespace too...
module ActionDispatch::Routing::UrlFor
  def resource_hierarchy_for(resource)
    case resource.class.name
    when "Budget::Investment"
      [resource.budget, resource]
    when "Budget::Investment::Milestone"
      [resource.investment.budget, resource.investment, resource]
    when "Legislation::Annotation"
      [resource.draft_version.process, resource.draft_version, resource]
    when "Legislation::Proposal", "Legislation::Question", "Legislation::DraftVersion"
      [resource.process, resource]
    when "Topic"
      [resource.community, resource]
    else
      resource
    end
  end

  def polymorphic_hierarchy_path(resource)
    # Unfortunately, we can't use polymorphic routes because there
    # are cases where polymorphic_path doesn't get the named routes properly.
    # Example:
    #
    # polymorphic_path([legislation_proposal.process, legislation_proposal])
    #
    # That line tries to find legislation_process_legislation_proposal_path
    # while the correct route would be legislation_process_proposal_path
    #
    # We probably need to define routes differently in order to be able to use
    # polymorphic_path which might be possible with Rails 5.1 `direct` and
    # `resolve` methods.

    resources = resource_hierarchy_for(resource)

    case resource.class.name
    when "Budget::Investment"
      # polymorphic_path would return budget_budget_investment_path
      budget_investment_path(*resources)
    when "Legislation::Annotation"
      # polymorphic_path would return:
      # "legislation_process_legislation_draft_version_legislation_annotation_path"
      legislation_process_draft_version_annotation_path(*resources)
    when "Legislation::Proposal"
      # polymorphic_path would return legislation_process_legislation_proposal_path
      legislation_process_proposal_path(*resources)
    when "Legislation::Question"
      # polymorphic_path would return legislation_process_legislation_question_path
      legislation_process_question_path(*resources)
    when "Poll::Question"
      # polymorphic_path would return poll_question_path
      question_path(*resources)
    else
      polymorphic_path(resources)
    end
  end
end
