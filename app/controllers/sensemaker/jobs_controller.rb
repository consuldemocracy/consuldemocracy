class Sensemaker::JobsController < ApplicationController
  include Sensemaker::ResourceTypeResolution

  skip_authorization_check

  def show
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    authorize! :read, @sensemaker_job

    unless @sensemaker_job.artefacts.complete?
      head :not_found
      nil
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def index
    resource_type, resource_id = [params[:resource_type].presence, params[:resource_id].presence]
    raise ArgumentError, "Unknown resource type: #{resource_type}" if resource_type.blank?

    @resource = sensemaker_find_resource(resource_type, resource_id)
    raise ActiveRecord::RecordNotFound, "Resource not found" unless @resource

    @parent_resource = load_parent_resource_for(@resource)
    @sensemaker_jobs = case @resource
                       when Poll
                         Sensemaker::Job.for_poll(@resource).order(finished_at: :desc)
                       when Legislation::Question
                         Sensemaker::Job.for_legislation_question(@resource).order(finished_at: :desc)
                       when Legislation::Process
                         Sensemaker::Job.for_process(@resource).order(finished_at: :desc)
                       else
                         Sensemaker::Job.published
                                        .where(analysable: @resource)
                                        .order(finished_at: :desc)
                       end
  rescue ActiveRecord::RecordNotFound, ArgumentError
    head :not_found
  end

  def all_proposals_index
    @parent_resource = nil
    @sensemaker_jobs = Sensemaker::Job.published
                                      .where(analysable_type: "Proposal", analysable_id: nil)
                                      .order(finished_at: :desc)
    render :index
  end

  def serve_report
    job = Sensemaker::Job.find(params[:id])
    authorize! :read, job

    if job.artefacts.complete?
      output_paths = job.artefacts.output_artefact_paths
      report_file_path = output_paths.find { |p| p.include?("html") } || output_paths.first
      send_file report_file_path,
                filename: File.basename(report_file_path),
                disposition: "inline",
                type: determine_content_type(report_file_path)
    else
      head :not_found
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

    def load_parent_resource_for(resource)
      case resource
      when Poll::Question
        resource.poll
      when Legislation::Question, Legislation::Proposal
        resource.process
      when Legislation::QuestionOption
        resource.question.process
      else
        nil
      end
    end

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
