class Admin::AdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @administrators = @administrators.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @administrator = Administrator.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
  end

  def create
    @administrator.user_id = params[:user_id]
    @administrator.save

    redirect_to admin_administrators_path
  end

  def destroy
    @administrator.destroy
    redirect_to admin_administrators_path
  end
end
