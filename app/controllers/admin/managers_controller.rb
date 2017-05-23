class Admin::ManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @managers = @managers.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @manager = Manager.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
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
