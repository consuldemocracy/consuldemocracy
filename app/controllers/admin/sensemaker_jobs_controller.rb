class Admin::SensemakerJobsController < Admin::BaseController
  def index
    @sensemaker_jobs = Sensemaker::Job.order(created_at: :desc)
    @running_jobs = Sensemaker::Job.where.not(started_at: nil).where(finished_at: nil)
    # TODO: It would be better to get these from the Delayed::Job table with the sensemaker queue
    # @running_jobs = Delayed::Job.where(queue: "sensemaker").where(run_at: nil..Time.current)
    # puts "Running jobs: #{@running_jobs.inspect}"
    # NB - delayed_job_config.rb is set up to run jobs synchronoushly in development so this won't quite work
  end

  def new
    @sensemaker_job = Sensemaker::Job.new
  end

  def create
    valid_params = sensemaker_job_params.to_h
    valid_params.merge!(user: current_user, started_at: Time.current)
    @sensemaker_job = Sensemaker::Job.create!(valid_params)

    Sensemaker::JobRunner.new(@sensemaker_job).run

    redirect_to admin_sensemaker_jobs_path,
                notice: t("admin.sensemaker.script_info", email: current_user.email)
  end

  def preview
    valid_params = sensemaker_job_params.to_h
    valid_params.merge!(user: current_user, started_at: Time.current)
    sensemaker_job = Sensemaker::Job.new(valid_params)

    @result = ""
    status = 200
    begin
      @result += Sensemaker::JobRunner.compile_context(sensemaker_job.commentable)
      @result += "\n\n---------Input CSV--------\n\n"
      @result += Sensemaker::CsvExporter.new(sensemaker_job.commentable).export_to_string
      filename = "#{sensemaker_job.commentable_type}-#{sensemaker_job.commentable_id}".parameterize
    rescue Exception => e
      @result += "Error: #{e.message}"
      status = 500
    end

    respond_to do |format|
      format.html { render plain: @result, layout: false, status: status }
      format.js
      format.csv { send_data @result, filename: "#{filename}-input.csv", status: status }
    end
  end

  def destroy
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    @sensemaker_job.destroy

    redirect_to admin_sensemaker_jobs_path,
                notice: t("admin.sensemaker.notice.deleted_job")
  end

  def download
    @sensemaker_job = Sensemaker::Job.find(params[:id])
    job_runner = Sensemaker::JobRunner.new(@sensemaker_job)
    send_file job_runner.output_file, filename: job_runner.output_file_name
  end

  def cancel
    Delayed::Job.where(queue: "sensemaker").destroy_all
    Sensemaker::Job.unfinished.destroy_all

    redirect_to admin_sensemaker_jobs_path,
                notice: t("admin.sensemaker.notice.cancelled_jobs")
  end

  private

    def sensemaker_job_params
      params.require(:sensemaker_job).permit(:commentable_type, :commentable_id, :script)
    end
end
