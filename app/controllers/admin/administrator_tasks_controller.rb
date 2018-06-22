class Admin::AdministratorTasksController < Admin::BaseController
  helper_method :administrator_task

  def index
    authorize! :index, AdministratorTask
    @administrator_tasks = AdministratorTask.pending
  end

  def edit
    authorize! :edit, administrator_task
  end

  def update
    authorize! :update, administrator_task

    administrator_task.update(user: current_user, executed_at: Time.now)
    redirect_to admin_administrator_tasks_path, { flash: { notice: t('.success') } }
  end

  private

  def administrator_task
    @administrator_task ||= AdministratorTask.find(params[:id])
  end
end
