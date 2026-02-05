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
    if params[:resource_type].present? && params[:resource_id].present?
      resource_type = map_resource_type_to_model(params[:resource_type])
      @resource = resource_type.find(params[:resource_id])
      @parent_resource = load_parent_resource_for(@resource)
      @sensemaker_jobs = Sensemaker::Job.published
                                        .where(analysable_type: resource_type.name,
                                               analysable_id: params[:resource_id])
                                        .order(finished_at: :desc)
    else
      head :not_found
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def all_proposals_index
    @parent_resource = nil
    @sensemaker_jobs = Sensemaker::Job.published
                                      .where(analysable_type: "Proposal", analysable_id: nil)
                                      .order(finished_at: :desc)
    render :index
  end

  def processes_index
    @parent_resource = Legislation::Process.find(params[:process_id])
    @sensemaker_jobs = Sensemaker::Job.published.for_process(@parent_resource).order(finished_at: :desc)
    render :index
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def serve_report
    job = Sensemaker::Job.find(params[:id])
    authorize! :read, job

    if job.has_outputs?
      report_file_path = job.persisted_output
      if job.script.eql?("runner.ts")
        report_file_path = job.output_artifact_paths.select { |path| path.include?("html") }.first
      end
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
