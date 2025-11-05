class Sensemaker::ReportComponent < ApplicationComponent
  attr_reader :analysable_resource

  def initialize(analysable_resource)
    @analysable_resource = analysable_resource
  end

  def render?
    feature?(:sensemaker) && latest_successful_job.present? && report_available?
  end

  def report_url
    return nil unless latest_successful_job&.has_outputs?

    sensemaker_job_path(latest_successful_job.id)
  end

  def report_available?
    latest_successful_job.present? && latest_successful_job.has_outputs?
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
