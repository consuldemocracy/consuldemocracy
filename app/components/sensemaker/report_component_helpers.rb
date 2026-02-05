module Sensemaker::ReportComponentHelpers
  extend ActiveSupport::Concern

  SCRIPT_REPORT = "single-html-build.js".freeze
  SCRIPT_SUMMARY = "runner.ts".freeze

  def display_title_for(record)
    return nil unless record

    if record.respond_to?(:title)
      record.title
    elsif record.respond_to?(:name)
      record.name
    else
      record.class.name.humanize
    end
  end

  def sensemaker_tools_link
    link_to(t("sensemaker.report_view.sensemaker_tools_link"),
            "https://jigsaw-code.github.io/sensemaking-tools/", target: "_blank", rel: "noopener")
  end

  def introductory_text
    t("sensemaker.job_index.page_intro", link: sensemaker_tools_link).html_safe
  end

  def has_jobs?
    jobs.any?
  end

  def script_type_tag(job)
    case job_script_kind(job)
    when :report
      t("sensemaker.job_index.script_type.report")
    when :summary
      t("sensemaker.job_index.script_type.summary")
    else
      job.script
    end
  end

  def view_job_text(job)
    case job_script_kind(job)
    when :report
      t("sensemaker.job_index.view_report")
    when :summary
      t("sensemaker.job_index.view_summary")
    else
      t("sensemaker.job_index.view_job")
    end
  end

  def job_path(job)
    sensemaker_job_path(job)
  end

  def job_artefact_path(job)
    serve_report_sensemaker_job_path(job)
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

  def analysis_type_badge_class(job)
    case job_script_kind(job)
    when :report
      "badge-report"
    when :summary
      "badge-summary"
    else
      "badge-default"
    end
  end

  def contextual_info_title
    t("sensemaker.job_index.contextual_info.title")
  end

  def contextual_info_how_created
    t("sensemaker.job_index.contextual_info.how_created")
  end

  def contextual_info_what_to_expect
    t("sensemaker.job_index.contextual_info.what_to_expect")
  end

  def contextual_info_more_info
    link_text = t("sensemaker.job_index.contextual_info.more_info_link")
    link = link_to(link_text,
                   "https://jigsaw-code.github.io/sensemaking-tools/",
                   target: "_blank",
                   rel: "noopener")
    t("sensemaker.job_index.contextual_info.more_info", link: link).html_safe
  end

  def breadcrumb_separator
    t("sensemaker.job_index.breadcrumb.separator")
  end

  def contextual_info_type_key_for(record)
    return nil if record.blank?

    case record
    when Proposal
      "proposal"
    when Debate
      "debate"
    when Legislation::Proposal
      "legislation_proposal"
    when Legislation::Question
      "legislation_question"
    when Legislation::Process
      "legislation_process"
    when Poll
      "poll"
    when Budget
      "budget"
    else
      "generic"
    end
  end

  def this_resource_phrase_for(record)
    return nil if record.blank?

    case record
    when Proposal
      t("sensemaker.job_index.hero_resource_types.proposal")
    when Debate
      t("sensemaker.job_index.hero_resource_types.debate")
    when Legislation::Question
      t("sensemaker.job_index.hero_resource_types.legislation_question")
    when Legislation::Proposal
      t("sensemaker.job_index.hero_resource_types.legislation_proposal")
    when Legislation::Process
      t("sensemaker.job_index.hero_resource_types.legislation")
    when Poll
      t("sensemaker.job_index.hero_resource_types.poll")
    when Poll::Question
      t("sensemaker.job_index.hero_resource_types.poll_question")
    when Budget
      t("sensemaker.job_index.hero_resource_types.budget")
    else
      "this #{record.class.name.humanize.downcase}"
    end
  end

  def target_resource_link_for(job)
    label = target_resource_display_label(job)
    path = target_resource_path(job)
    return nil if label.blank? || path.blank?

    link_to(label, path)
  rescue StandardError
    nil
  end

  def target_resource_display_label(job)
    analysable = job.analysable
    return nil if analysable.blank?
    return nil if job.analysable_id.nil? && job.analysable_type == "Proposal"

    case analysable
    when Legislation::QuestionOption
      analysable.question.title
    else
      job.conversation.target_label
    end
  rescue StandardError
    nil
  end

  def path_for_sensemaker_resource(resource)
    return nil if resource.blank?

    case resource
    when Poll
      poll_path(id: resource.slug || resource.id)
    when Legislation::Question
      legislation_process_question_path(resource.process, resource)
    when Legislation::QuestionOption
      legislation_process_question_path(resource.question.process, resource.question)
    when Debate, Proposal
      polymorphic_path(resource)
    when Budget
      budget_path(resource)
    when Budget::Group
      budget_path(resource.budget)
    when Legislation::Proposal
      legislation_process_proposal_path(resource.process, resource)
    when Poll::Question
      poll_path(resource.poll)
    else
      nil
    end
  rescue StandardError
    nil
  end

  def parent_resource_path_for(parent_resource)
    return nil if parent_resource.blank?

    case parent_resource
    when Poll
      poll_path(id: parent_resource.slug || parent_resource.id)
    when Legislation::Process
      legislation_process_path(parent_resource)
    when Budget
      budget_path(parent_resource)
    else
      nil
    end
  rescue StandardError
    nil
  end

  def target_resource_path(job)
    analysable = job.analysable
    return nil if analysable.blank?
    return nil if job.analysable_id.nil? && job.analysable_type == "Proposal"

    path_for_sensemaker_resource(analysable)
  end

  def jobs_index_path_for(resource)
    return sensemaker_all_proposals_jobs_path if resource.eql?(Proposal)

    case resource
    when Budget
      budget_sensemaking_path(resource)
    when Legislation::Process
      sensemaker_legislation_process_jobs_path(resource.id)
    when Budget::Group
      budget_sensemaking_path(resource.budget)
    else
      resource_type = resource_type_for_route(resource.class)
      sensemaker_resource_jobs_path(resource_type: resource_type, resource_id: resource.id)
    end
  end

  private

    def job_script_kind(job)
      case job.script
      when SCRIPT_REPORT
        :report
      when SCRIPT_SUMMARY
        :summary
      else
        :other
      end
    end

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
