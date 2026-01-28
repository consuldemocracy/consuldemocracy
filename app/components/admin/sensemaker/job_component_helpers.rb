module Admin::Sensemaker::JobComponentHelpers
  extend ActiveSupport::Concern

  def job_status_class
    "job-status-#{job.status.downcase}"
  end

  def analysable_title
    if job.analysable.present?
      job.conversation.target_label(format: :short)
    elsif job.analysable_type == "Proposal" && job.analysable_id.nil?
      "All Proposals"
    else
      "(deleted)"
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
    case job.status
    when "Completed"
      "Completed at #{job.finished_at.strftime("%Y-%m-%d %H:%M")}"
    when "Failed"
      "Failed at #{job.finished_at.strftime("%Y-%m-%d %H:%M")}"
    when "Running"
      "Started at #{job.started_at.strftime("%Y-%m-%d %H:%M")}"
    when "Cancelled"
      "Cancelled at #{job.finished_at.strftime("%Y-%m-%d %H:%M")}"
    else
      "Created at #{job.created_at.strftime("%Y-%m-%d %H:%M")}"
    end
  end

  def parent_job?
    job.parent_job_id.blank?
  end

  def parent_job
    @parent_job ||= job.parent_job if job.parent_job_id.present?
  end
end
