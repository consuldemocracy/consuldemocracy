class Sensemaker::JobsController < ApplicationController
  skip_authorization_check

  def show
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    authorize! :read, @sensemaker_job

    unless @sensemaker_job.has_outputs?
      head :not_found
      nil
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def index
    if params[:process_id].present?
      @parent_resource = Legislation::Process.find(params[:process_id])
      @sensemaker_jobs = Sensemaker::Job.published.for_process(@parent_resource).order(finished_at: :desc)
    elsif params[:budget_id].present?
      @parent_resource = Budget.find(params[:budget_id])
      @sensemaker_jobs = Sensemaker::Job.published.for_budget(@parent_resource).order(finished_at: :desc)
    else
      head :not_found
    end
  end

  def serve_report
    job = Sensemaker::Job.find(params[:id])
    authorize! :read, job

    if job.has_outputs?
      send_file job.persisted_output,
                filename: File.basename(job.persisted_output),
                disposition: "inline",
                type: determine_content_type(job.persisted_output)
    else
      head :not_found
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

    def determine_content_type(file_path)
      case File.extname(file_path).downcase
      when ".html"
        "text/html"
      when ".csv"
        "text/csv"
      when ".json"
        "application/json"
      when ".txt"
        "text/plain"
      else
        "application/octet-stream"
      end
    end
end
