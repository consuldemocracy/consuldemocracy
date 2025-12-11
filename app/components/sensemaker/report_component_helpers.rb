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
end
