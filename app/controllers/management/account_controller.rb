class Management::AccountController < Management::BaseController

  before_action :only_verified_users

  def show
    @delete_user = params[:delete_user]
    @edit_email = params[:edit_email]
  end

  def update
    if managed_user.update(manage_account_params)
      if params[:edit_email]
        @sent_email = true
      else
        flash[:notice] = t("flash.actions.save_changes.notice")
      end
    else
      @edit_email = params[:edit_email]
    end
    render :show
  end

  def edit
  end

  def print_password
  end

  def reset_password
    managed_user.send_reset_password_instructions
    redirect_to management_account_path, notice: t("management.account.edit.password.reset_email_send")
  end

  def change_password
    if managed_user.reset_password(params[:user][:password], params[:user][:password])
      session[:new_password] = params[:user][:password]
      redirect_to print_password_management_account_path
    else
      render :edit_password_manually
    end
  end

  private

    def only_verified_users
      check_verified_user t("management.account.alert.unverified_user")
    end

    def manage_account_params
      params.require(:user).permit(:email)
    end

end
