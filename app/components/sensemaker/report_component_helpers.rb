module Sensemaker::ReportComponentHelpers
  extend ActiveSupport::Concern

  def target_resource_link_for(job)
    analysable = job.analysable
    return nil if analysable.blank?
    return nil if job.analysable_id.nil? && job.analysable_type == "Proposal"

    link_label = job.conversation.target_label
    link_path = case analysable
    when Poll
      poll_path(id: analysable.slug || analysable.id)
    when Legislation::Question
      legislation_process_question_path(analysable.process, analysable)
    when Legislation::QuestionOption
      link_label = analysable.question.title
      legislation_process_question_path(analysable.question.process, analysable.question)
    when Debate, Proposal
      polymorphic_path(analysable)
    when Budget
      budget_path(analysable)
    when Budget::Group
      budget_path(analysable.budget)
    when Legislation::Proposal
      legislation_process_proposal_path(analysable.process, analysable)
    else
      return nil
                end

    link_to(link_label, link_path)
  rescue
    nil
  end

  def jobs_index_path_for(resource)
    return sensemaker_all_proposals_jobs_path if resource.eql?(Proposal)

    case resource
    when Budget
      sensemaker_budget_jobs_path(resource.id)
    when Legislation::Process
      sensemaker_legislation_process_jobs_path(resource.id)
    when Budget::Group
      sensemaker_budget_jobs_path(resource.budget_id)
    else
      resource_type = resource_type_for_route(resource.class)
      sensemaker_resource_jobs_path(resource_type: resource_type, resource_id: resource.id)
    end
  end

  private

  def resource_type_for_route(model_class)
    case model_class.name
    when "Debate"
      "debates"
    when "Proposal"
      "proposals"
    when "Poll"
      "polls"
    when "Poll::Question"
      "poll_questions"
    when "Legislation::Question"
      "legislation_questions"
    when "Legislation::Proposal"
      "legislation_proposals"
    when "Legislation::QuestionOption"
      "legislation_question_options"
    when "Topic"
      "topics"
    else
      raise ArgumentError, "Unknown resource type for route: #{model_class.name}"
    end
  end
end
