class Sensemaker::ReportLinkComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :analysable_resource

  def initialize(analysable_resource)
    @analysable_resource = analysable_resource
  end

  def render?
    Sensemaker.enabled? && report_available?
  end

  def before_render
    @admin_preview = helpers.current_user&.administrator?
  end

  def admin_preview?
    @admin_preview == true
  end

  def report_available?
    Sensemaker::Job
      .for_analysable(analysable_for_report, published_only: !admin_preview?)
      .publishable_candidates
      .exists?
  end

  def analysis_title
    t("sensemaker.analysis.title")
  end

  def analysis_description
    if analysable_resource == Proposal
      t("sensemaker.analysis.description_all_proposals")
    else
      t("sensemaker.analysis.description",
        this_resource: this_resource_phrase_for(analysable_resource))
    end
  end

  def view_report_text
    t("sensemaker.analysis.view_report")
  end

  def link_to_analysis
    link_to view_report_text, jobs_index_path_for(analysable_resource), class: "button hollow expanded",
                                                                        target: "_blank"
  end

  private

    def analysable_for_report
      analysable_resource.is_a?(Budget::Group) ? analysable_resource.budget : analysable_resource
    end
end
