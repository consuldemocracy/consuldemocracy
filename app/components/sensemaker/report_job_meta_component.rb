class Sensemaker::ReportJobMetaComponent < ApplicationComponent
  attr_reader :job

  def initialize(job)
    @job = job
  end

  def target_resource_link
    analysable = @job.analysable
    return nil if analysable.blank?
    return nil if @job.analysable_id.nil? && @job.analysable_type == "Proposal"

    link_label = @job.conversation.target_label
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

  def run_timestamp
    return nil unless @job.finished_at

    l(@job.finished_at, format: :long)
  end

  def comments_analysed_count
    @job.comments_analysed || 0
  end

  def report_url
    serve_report_sensemaker_job_path(@job.id)
  end

  def view_report_text
    t("sensemaker.report_view.view_report")
  end
end
