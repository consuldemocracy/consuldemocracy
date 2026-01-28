class Sensemaker::JobIndexComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :jobs, :parent_resource, :resource

  def initialize(jobs:, parent_resource: nil, resource: nil)
    @jobs = jobs
    @parent_resource = parent_resource
    @resource = resource
  end

  def sensemaker_tools_link
    link_to(t("sensemaker.report_view.sensemaker_tools_link"),
            "https://jigsaw-code.github.io/sensemaking-tools/", target: "_blank", rel: "noopener")
  end

  def introductory_text
    t("sensemaker.report_index.intro_text", link: sensemaker_tools_link).html_safe
  end

  def has_jobs?
    @jobs.any?
  end

  def page_title
    if @resource
      t("sensemaker.job_index.title_with_resource", resource_name: resource_title)
    elsif @parent_resource
      t("sensemaker.job_index.title_with_parent", parent_name: parent_resource_title)
    else
      t("sensemaker.job_index.title")
    end
  end

  def parent_resource_title
    return nil unless @parent_resource

    if @parent_resource.respond_to?(:title)
      @parent_resource.title
    elsif @parent_resource.respond_to?(:name)
      @parent_resource.name
    else
      @parent_resource.class.name.humanize
    end
  end

  def parent_resource_link
    return nil unless @parent_resource

    link_label = parent_resource_title
    link_path = case @parent_resource
    when Poll
      poll_path(id: @parent_resource.slug || @parent_resource.id)
    when Legislation::Process
      legislation_process_path(@parent_resource)
    when Budget
      budget_path(@parent_resource)
    else
      nil
                end

    return nil unless link_path

    link_to(link_label, link_path)
  rescue
    nil
  end

  def resource_title
    return nil unless @resource

    if @resource.respond_to?(:title)
      @resource.title
    elsif @resource.respond_to?(:name)
      @resource.name
    else
      @resource.class.name.humanize
    end
  end

  def resource_path
    return nil unless @resource

    case @resource
    when Poll
      poll_path(id: @resource.slug || @resource.id)
    when Legislation::Question
      legislation_process_question_path(@resource.process, @resource)
    when Legislation::QuestionOption
      legislation_process_question_path(@resource.question.process, @resource.question)
    when Debate, Proposal
      polymorphic_path(@resource)
    when Budget
      budget_path(@resource)
    when Budget::Group
      budget_path(@resource.budget)
    when Legislation::Proposal
      legislation_process_proposal_path(@resource.process, @resource)
    when Poll::Question
      poll_path(@resource.poll)
    else
      nil
    end
  rescue
    nil
  end

  def script_type_tag(job)
    case job.script
    when "single-html-build.js"
      t("sensemaker.job_index.script_type.report")
    when "runner.ts"
      t("sensemaker.job_index.script_type.summary")
    else
      job.script
    end
  end

  def view_job_text(job)
    case job.script
    when "single-html-build.js"
      t("sensemaker.job_index.view_report")
    when "runner.ts"
      t("sensemaker.job_index.view_summary")
    else
      t("sensemaker.job_index.view_job")
    end
  end

  def job_path(job)
    sensemaker_job_path(job)
  end

  def formatted_finished_at(job)
    return nil unless job.finished_at

    l(job.finished_at, format: :long)
  end

  def comments_analysed_count(job)
    job.comments_analysed || 0
  end

  def empty_message
    t("sensemaker.report_index.empty")
  end
end
