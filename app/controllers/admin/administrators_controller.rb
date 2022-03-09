class Admin::AdministratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @administrators = @administrators.page(params[:page])
  end

  def search
    @users = User.search(params[:search])
                 .includes(:administrator)
                 .page(params[:page])
  end

  def create
    @administrator.user_id = params[:user_id]
    @administrator.save!

    redirect_to admin_administrators_path
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
      params.require(:administrator).permit(:description)
    end
end
