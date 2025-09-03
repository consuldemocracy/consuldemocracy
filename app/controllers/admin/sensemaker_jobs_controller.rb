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
