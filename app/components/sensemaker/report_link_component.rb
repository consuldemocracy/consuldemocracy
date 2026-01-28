class Sensemaker::ReportLinkComponent < ApplicationComponent
  include Sensemaker::ReportComponentHelpers

  attr_reader :analysable_resource

  def initialize(analysable_resource)
    @analysable_resource = analysable_resource
  end

  def render?
    feature?(:sensemaker) && report_available?
  end

  def report_available?
    case analysable_resource
    when Budget
      Sensemaker::Job.for_budget(analysable_resource).exists?
    when Legislation::Process
      Sensemaker::Job.for_process(analysable_resource).exists?
    when Budget::Group
      Sensemaker::Job.for_budget(analysable_resource.budget).exists?
    else
      if analysable_resource.class.name == "Proposal" && analysable_resource.id.nil?
        Sensemaker::Job.published.where(analysable_type: "Proposal", analysable_id: nil).exists?
      else
        Sensemaker::Job.published
                       .where(analysable_type: analysable_resource.class.name,
                              analysable_id: analysable_resource.id)
                       .exists?
      end
    end
  end

  def analysis_title
    t("sensemaker.analysis.title")
  end

  def analysis_description
    t("sensemaker.analysis.description",
      subject: t("activerecord.models.#{analysable_resource.class.model_name.i18n_key}.one").downcase)
  end

  def view_report_text
    t("sensemaker.analysis.view_report")
  end

  def link_to_analysis
    link_to view_report_text, jobs_index_path_for(analysable_resource), class: "button hollow expanded",
                                                                        target: "_blank"
  end
end
