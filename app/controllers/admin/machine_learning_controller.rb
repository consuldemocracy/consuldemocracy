class Admin::MachineLearningController < Admin::BaseController
  before_action :load_machine_learning_job, only: [:show, :execute]

  def show
  end

  def execute
    # 1. Standardize parameters
    script = params[:script]
    is_dry_run = params[:dry_run] == "1" || params[:dry_run] == "true"

    @job = MachineLearningJob.create!(
      script: script,
      user: current_user,
      started_at: Time.current,
      dry_run: is_dry_run,
      config: { "force_update" => params[:force_update] }
    )

    ::MachineLearning.new(@job).delay(queue: "machine_learning").run

    notice_msg = is_dry_run ? "Dry run started (Background)" : "Job started in background."
    redirect_to admin_machine_learning_path, notice: notice_msg
  end

  def cancel
    MachineLearningJob.delete_all

    redirect_to admin_machine_learning_path,
                notice: t("admin.machine_learning.notice.delete_generated_content")
  end

  private

    def load_machine_learning_job
      @machine_learning_job = MachineLearningJob.order(created_at: :desc).first_or_initialize
    end
end
