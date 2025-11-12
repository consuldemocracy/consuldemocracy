class Sensemaker::ReportViewComponent < ApplicationComponent
  attr_reader :sensemaker_job
  use_helpers :link_to, :polymorphic_path

  def initialize(sensemaker_job)
    @sensemaker_job = sensemaker_job
  end

  def introductory_text
    t("sensemaker.report_view.intro_text", link: sensemaker_tools_link).html_safe
  end

  def sensemaker_tools_link
    link_to(t("sensemaker.report_view.sensemaker_tools_link"),
            "https://jigsaw-code.github.io/sensemaking-tools/", target: "_blank", rel: "noopener")
  end

  def explanatory_text
    analysable = @sensemaker_job.analysable

    if @sensemaker_job.analysable_id.nil? && @sensemaker_job.analysable_type == "Proposal"
      return t("sensemaker.report_view.explanatory_text.all_proposals")
    end

    if analysable.blank?
      return t("sensemaker.report_view.explanatory_text.generic", resource_name: "unknown")
    end

    case analysable
    when Poll
      t("sensemaker.report_view.explanatory_text.poll", poll_name: target_resource_link).html_safe
    when Legislation::Question
      t("sensemaker.report_view.explanatory_text.legislation_question",
        question_name: target_resource_link).html_safe
    when Legislation::QuestionOption
      t("sensemaker.report_view.explanatory_text.legislation_question_option",
        question_name: target_resource_link,
        option_value: analysable.value).html_safe
    when Debate
      t("sensemaker.report_view.explanatory_text.debate", debate_title: target_resource_link).html_safe
    when Proposal
      t("sensemaker.report_view.explanatory_text.proposal", proposal_title: target_resource_link).html_safe
    when Budget
      t("sensemaker.report_view.explanatory_text.budget", budget_name: target_resource_link).html_safe
    when Budget::Group
      t("sensemaker.report_view.explanatory_text.budget_group", group_name: target_resource_link).html_safe
    when Legislation::Proposal
      t("sensemaker.report_view.explanatory_text.legislation_proposal",
        proposal_title: target_resource_link).html_safe
    else
      t("sensemaker.report_view.explanatory_text.generic", resource_name: target_resource_link).html_safe
    end
  end

  def target_resource_link
    analysable = @sensemaker_job.analysable
    return nil if analysable.blank?
    return nil if @sensemaker_job.analysable_id.nil? && @sensemaker_job.analysable_type == "Proposal"

    link_label = @sensemaker_job.conversation.target_label
    link_path = case analysable
    when Poll
      poll_path(id: analysable.slug || analysable.id)
    when Legislation::Question
      legislation_process_question_path(analysable.process, analysable)
    when Legislation::QuestionOption
      link_label = analysable.question.title
      legislation_process_question_path(analysable.question.process, analysable.question)
    when Debate || Proposal
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

  def report_description
    t("sensemaker.report_view.report_description")
  end
end
