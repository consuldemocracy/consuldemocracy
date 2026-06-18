module Admin::Sensemaker::JobComponentHelpers
  extend ActiveSupport::Concern
  include Sensemaker::ReportComponentHelpers

  def job_status_class
    "job-status-#{job.status.downcase}"
  end

  def analysable_title
    if job.analysable.present?
      job.conversation.target_label(format: :short)
    elsif job.analysable_type == "Proposal" && job.analysable_id.nil?
      I18n.t("admin.sensemaker.job_show.analysable_all_proposals")
    else
      I18n.t("admin.sensemaker.job_show.analysable_deleted")
    end
  end

  def has_error?
    job.error.present? && job.status.eql?("Failed")
  end

  def can_download?
    job.finished? && !job.errored?
  end

  def can_publish?
    job.publishable?
  end

  def is_published?
    job.published?
  end

  def status_text
    time_format = "%Y-%m-%d %H:%M"
    case job.status
    when "Completed"
      I18n.t("admin.sensemaker.job_show.status_completed_at", time: job.finished_at.strftime(time_format))
    when "Failed"
      I18n.t("admin.sensemaker.job_show.status_failed_at", time: job.finished_at.strftime(time_format))
    when "Running"
      I18n.t("admin.sensemaker.job_show.status_started_at", time: job.started_at.strftime(time_format))
    when "Cancelled"
      I18n.t("admin.sensemaker.job_show.status_cancelled_at", time: job.finished_at.strftime(time_format))
    else
      I18n.t("admin.sensemaker.job_show.status_created_at", time: job.created_at.strftime(time_format))
    end
  end

  def parent_job?
    job.parent_job_id.blank?
  end

  def parent_job
    @parent_job ||= job.parent_job if job.parent_job_id.present?
  end
end
