class Admin::AdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @administrators = @administrators.page(params[:page])
  end

  def search
    @users = User.search(params[:search]).includes(:administrator).page(params[:page])
  end

  def create
    user = User.find(params[:user_id])
    if user.can_be_administrator?
      @administrator.user_id = user.id
      @administrator.save!
      redirect_to admin_administrators_path, notice: "Administrator was successfully created."
    else
      redirect_to admin_administrators_path, alert: "User is not allowed to be an administrator."
    end
  end

  def destroy
    if current_user.id == @administrator.user_id
      flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
    else
      @administrator.destroy
    end

    redirect_to admin_administrators_path
  end

  def edit
  end

  def update
    if @administrator.update(update_administrator_params)
      notice = t("admin.administrators.form.updated")
      redirect_to admin_administrators_path, notice: notice
    else
      render :edit
    end
  end

  private

    def update_administrator_params
      params.require(:administrator).permit(allowed_params)
    end

    def allowed_params
      [:description]
    end
end
