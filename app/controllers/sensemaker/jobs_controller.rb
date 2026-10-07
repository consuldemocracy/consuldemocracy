class Sensemaker::JobsController < ApplicationController
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
    if params[:resource_type].blank? || params[:resource_id].blank?
      head :not_found
      return
    end

    resource_type = map_resource_type_to_model(params[:resource_type])
    @resource = resource_type.find(params[:resource_id])
    @parent_resource = load_parent_resource_for(@resource)
    @sensemaker_jobs = jobs_for_analysable(@resource)
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def all_proposals_index
    @parent_resource = nil
    @sensemaker_jobs = jobs_for_analysable(Proposal)
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

    def jobs_for_analysable(record)
      Sensemaker::Job
        .for_analysable(record, published_only: !admin_preview?)
        .publishable_candidates
        .order(finished_at: :desc)
    end

    def admin_preview?
      current_user&.administrator?
    end

    def map_resource_type_to_model(resource_type)
      case resource_type
      when "debates"
        Debate
      when "proposals"
        Proposal
      when "polls"
        Poll
      when "topics"
        Topic
      when "poll_questions"
        Poll::Question
      when "legislation_processes"
        Legislation::Process
      when "legislation_questions"
        Legislation::Question
      when "legislation_proposals"
        Legislation::Proposal
      when "legislation_question_options"
        Legislation::QuestionOption
      else
        raise ArgumentError, "Unknown resource type: #{resource_type}"
      end
    end

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
