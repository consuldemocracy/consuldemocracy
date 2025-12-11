class Sensemaker::ReportLinkComponent < ApplicationComponent
  attr_reader :analysable_resource, :link_to_index

  def initialize(analysable_resource, link_to_index: false)
    @analysable_resource = analysable_resource
    @link_to_index = link_to_index
  end

  def render?
    feature?(:sensemaker) && report_available?
  end

  def report_url
    return nil unless latest_successful_job&.has_outputs?

    sensemaker_job_path(latest_successful_job.id)
  end

  def report_available?
    if link_to_index
      case analysable_resource
      when Budget
        Sensemaker::Job.for_budget(analysable_resource).exists?
      when Legislation::Process
        Sensemaker::Job.for_process(analysable_resource).exists?
      else
        false
      end
    else
      latest_successful_job.present? && latest_successful_job.has_outputs?
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
    if link_to_index
      link_to view_report_text, [:sensemaker, analysable_resource, :jobs], class: "button hollow expanded",
                                                                           target: "_blank"
    else
      link_to view_report_text, report_url, class: "button hollow expanded", target: "_blank"
    end
  end

  private

    def latest_successful_job
      @latest_successful_job ||= Sensemaker::Job
                                 .where(analysable_type: analysable_resource.class.name,
                                        analysable_id: analysable_resource.id)
                                 .successful
                                 .published
                                 .order(finished_at: :desc)
                                 .first
    end
end
