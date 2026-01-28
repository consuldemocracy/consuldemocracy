class Sensemaker::GroupedJobIndexComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :jobs, :parent_resource

  def initialize(jobs:, parent_resource: nil)
    @jobs = jobs
    @parent_resource = parent_resource
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

  def page_title
    if @parent_resource
      t("sensemaker.report_index.title_with_parent", parent_name: parent_resource_title)
    else
      t("sensemaker.report_index.title")
    end
  end

  def empty_message
    t("sensemaker.report_index.empty")
  end
end
