class Sensemaker::ReportViewComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :sensemaker_job

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
    target_resource_link_for(@sensemaker_job)
  end

  def report_description
    t("sensemaker.report_view.report_description")
  end
end
