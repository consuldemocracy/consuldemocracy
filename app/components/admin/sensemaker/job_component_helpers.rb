module Admin::Sensemaker::JobComponentHelpers
  extend ActiveSupport::Concern

  def job_status_class
    "job-status-#{job.status.downcase}"
  end

  def commentable_title
    job.commentable.present? ? job.commentable.title : "(deleted)"
  end

  def has_error?
    job.error.present? && job.status.eql?("Failed")
  end

  def can_download?
    job.finished? && !job.errored?
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
