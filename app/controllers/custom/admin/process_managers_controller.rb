#load Rails.root.join("app", "controllers", "admin", "process_managers_controller.rb")
class Admin::ProcessManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @process_managers = @process_managers.page(params[:page])
  end

  def search
    @users = User.search(params[:search]).includes(:process_manager).page(params[:page])
  end

  def create
    @process_manager.user_id = params[:user_id]
    @process_manager.save!

    redirect_to admin_process_managers_path
  end

  def destroy
    @process_manager.destroy!
    redirect_to admin_process_managers_path
  end
end
