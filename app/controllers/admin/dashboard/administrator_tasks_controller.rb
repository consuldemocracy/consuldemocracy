class Admin::Dashboard::AdministratorTasksController < Admin::Dashboard::BaseController
  has_filters %w[pending done]

  helper_method :administrator_task

  def index
    authorize! :index, ::Dashboard::AdministratorTask
    @administrator_tasks = ::Dashboard::AdministratorTask.send(@current_filter)
  end

  def edit
    authorize! :edit, administrator_task
  end

  def update
    authorize! :update, administrator_task

    administrator_task.update!(user: current_user, executed_at: Time.current)
    redirect_to admin_dashboard_administrator_tasks_path,
                { flash: { notice: t("admin.dashboard.administrator_tasks.update.success") }}
  end

  private

    def administrator_task
      @administrator_task ||= ::Dashboard::AdministratorTask.find(params[:id])
    end
end
