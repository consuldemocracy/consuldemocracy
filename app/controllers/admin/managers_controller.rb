class Admin::ManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @managers = @managers.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:manager)
                 .page(params[:page])
                 .for_render
  end

  def create
    @manager.user_id = params[:user_id]
    @manager.save

    redirect_to admin_managers_path
  end

  def destroy
    @manager.destroy
    redirect_to admin_managers_path
  end
end
