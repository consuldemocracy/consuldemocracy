class Sensemaker::ProcessJobIndexComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :jobs, :process

  def initialize(jobs:, process:)
    @jobs = jobs
    @process = process
  end

  def grouped_resources_for_process
    return [] if @jobs.none?

    groups = {}
    @jobs.each do |job|
      key = [job.analysable_type, job.analysable_id]
      groups[key] ||= []
      groups[key] << job
    end

    by_type = Hash.new { |h, k| h[k] = [] }
    groups.each do |key, resource_jobs|
      analysable_type, _analysable_id = key
      job = resource_jobs.first
      analysable = job.analysable
      next if analysable.blank?

      path = jobs_index_path_for(analysable)
      next if path.blank?

      report_count = resource_jobs.count { |j| j.script == Sensemaker::ReportComponentHelpers::SCRIPT_REPORT }
      summary_count = resource_jobs.count { |j| j.script == Sensemaker::ReportComponentHelpers::SCRIPT_SUMMARY }
      title = target_resource_display_label(job)
      by_type[analysable_type] << {
        title: title,
        path: path,
        report_count: report_count,
        summary_count: summary_count
      }
    end

    type_order = by_type.keys.uniq
    type_order.map do |analysable_type|
      type_key = analysable_type.underscore
      {
        type_key: type_key,
        type_label: t("sensemaker.report_index.group_titles.#{type_key}"),
        resources: by_type[analysable_type]
      }
    end
  end

  def reports_and_summaries_available_text(report_count:, summary_count:)
    reports = t("sensemaker.job_index.process.report_count", count: report_count)
    summaries = t("sensemaker.job_index.process.summary_count", count: summary_count)
    t("sensemaker.job_index.process.reports_and_summaries_available", reports: reports, summaries: summaries)
  end

  def parent_resource
    @process
  end

  def parent_resource_title
    display_title_for(@process)
  end

  def parent_resource_path
    parent_resource_path_for(@process)
  end

  def breadcrumb_segments
    return [] unless parent_resource_path

    [{ text: parent_resource_title, path: parent_resource_path }]
  end

  def page_title
    t("sensemaker.report_index.title_with_parent", parent_name: parent_resource_title)
  end

  def hero_title
    resource_type_name = hero_parent_resource_type_name
    if resource_type_name
      t("sensemaker.job_index.hero_title_with_resource", resource_type: resource_type_name)
    else
      t("sensemaker.job_index.hero_title_all_proposals")
    end
  end

  def hero_parent_resource_type_name
    this_resource_phrase_for(@process)
  end

  def contextual_info_resource_intro
    parent_type_key = contextual_info_type_key_for(@process)
    return t("sensemaker.job_index.contextual_info.resource_intro.all_proposals") unless parent_type_key

    parent_title_text = parent_resource_title
    t("sensemaker.job_index.contextual_info.resource_intro.#{parent_type_key}",
      resource_title: parent_title_text)
  end

  def contextual_info_parent_resource_type_key
    contextual_info_type_key_for(@process)
  end
end
