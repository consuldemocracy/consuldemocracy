class Sensemaker::JobIndexComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :jobs, :parent_resource, :resource

  def initialize(jobs:, parent_resource: nil, resource: nil)
    @jobs = jobs
    @parent_resource = parent_resource
    @resource = resource
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
    display_title_for(@parent_resource)
  end

  def resource_title
    display_title_for(@resource)
  end

  def resource_path
    path_for_sensemaker_resource(@resource)
  end

  def hero_title
    resource_type_name = hero_resource_type_name
    if resource_type_name
      t("sensemaker.job_index.hero_title_with_resource", resource_type: resource_type_name)
    else
      t("sensemaker.job_index.hero_title_all_proposals")
    end
  end

  def hero_resource_type_name
    this_resource_phrase_for(@resource)
  end

  def contextual_info_resource_intro
    if @resource
      resource_type_key = contextual_info_type_key_for(@resource)
      resource_title_text = resource_title
      t("sensemaker.job_index.contextual_info.resource_intro.#{resource_type_key}",
        resource_title: resource_title_text)
    elsif @parent_resource
      parent_type_key = contextual_info_type_key_for(@parent_resource)
      parent_title_text = parent_resource_title
      t("sensemaker.job_index.contextual_info.resource_intro.#{parent_type_key}",
        resource_title: parent_title_text)
    else
      t("sensemaker.job_index.contextual_info.resource_intro.all_proposals")
    end
  end

  def contextual_info_resource_type_key
    contextual_info_type_key_for(@resource)
  end

  def contextual_info_parent_resource_type_key
    contextual_info_type_key_for(@parent_resource)
  end

  def breadcrumb_segments
    segments = []

    if @resource && resource_path
      segments << { text: resource_title, path: resource_path }
    elsif segments.empty?
      segments << { text: t("sensemaker.job_index.breadcrumb.all_proposals"), path: proposals_path }
    end

    segments
  end

  def parent_resource_path
    parent_resource_path_for(@parent_resource)
  end
end
