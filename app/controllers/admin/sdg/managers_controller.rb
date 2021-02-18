class Admin::SDG::ManagersController < Admin::BaseController
  load_and_authorize_resource instance_name: :sdg_manager, class: "SDG::Manager"

  def index
    if params[:search]
      @users = User.accessible_by(current_ability).search(params[:search]).page(params[:page])
    else
      @users = User.accessible_by(current_ability).sdg_managers.page(params[:page])
    end
  end

  def create
    @sdg_manager.user_id = params[:user_id]
    @sdg_manager.save!

    redirect_to admin_sdg_managers_path
  end

  def destroy
    @sdg_manager.destroy!
    redirect_to admin_sdg_managers_path
  end
end
