class Sensemaker::JobsController < ApplicationController
  skip_authorization_check

  def show
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
