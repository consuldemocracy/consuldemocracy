class Admin::SensemakerJobsController < Admin::BaseController
  def index
    @sensemaker_jobs = Sensemaker::Job.order(created_at: :desc)
    @running_jobs = Sensemaker::Job.where.not(started_at: nil).where(finished_at: nil)
    # TODO: It would be better to get these from the Delayed::Job table with the sensemaker queue
    # @running_jobs = Delayed::Job.where(queue: "sensemaker").where(run_at: nil..Time.current)
    # puts "Running jobs: #{@running_jobs.inspect}"
  end

  def new
    @sensemaker_job = Sensemaker::Job.new
  end

  def create
    @sensemaker_job = Sensemaker::Job.create!(script: params[:script],
                                  user: current_user,
                                  started_at: Time.current,
                                  finished_at: nil,
                                  error: nil)

    Sensemaker::JobRunner.new(@sensemaker_job).run

    redirect_to admin_sensemaker_path,
                notice: t("admin.sensemaker.script_info", email: current_user.email)
  end

  def cancel
    Delayed::Job.where(queue: "sensemaker").destroy_all
    Sensemaker::Job.unfinished.destroy_all

    redirect_to admin_sensemaker_path,
                notice: t("admin.sensemaker.notice.cancelled_jobs")
  end
end
