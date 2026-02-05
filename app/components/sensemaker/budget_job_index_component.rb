class Sensemaker::BudgetJobIndexComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :jobs, :budget

  def initialize(jobs:, budget:)
    @jobs = jobs
    @budget = budget
  end

  def grouped_jobs_for_budget
    return [] if @jobs.none?

    groups = {}
    @jobs.each do |job|
      key = [job.analysable_type, job.analysable_id]
      groups[key] ||= { target_title: nil, target_path: nil, jobs: [] }
      groups[key][:jobs] << job
      next if groups[key][:target_title].present?

      groups[key][:target_title] = target_resource_display_label(job)
      groups[key][:target_path] = target_resource_path(job)
    end
    groups.values
  end

  def parent_resource
    @budget
  end

  def parent_resource_title
    display_title_for(@budget)
  end

  def parent_resource_path
    parent_resource_path_for(@budget)
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
    this_resource_phrase_for(@budget)
  end

  def contextual_info_resource_intro
    parent_type_key = contextual_info_type_key_for(@budget)
    return t("sensemaker.job_index.contextual_info.resource_intro.all_proposals") unless parent_type_key

    parent_title_text = parent_resource_title
    t("sensemaker.job_index.contextual_info.resource_intro.#{parent_type_key}",
      resource_title: parent_title_text)
  end

  def contextual_info_parent_resource_type_key
    contextual_info_type_key_for(@budget)
  end
end
