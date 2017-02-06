class Management::UsersController < Management::BaseController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
    @user.terms_of_service = '1'
    verificado = verificar_residencia
    @user.residence_verified_at = verificado
    @user.verified_at = verificado

    if verificado && @user.save then
      render :show
    else
      flash[:alert] = 'Usuario no verificado en el padrón municipal'
      render :new
    end
  end

  def erase
    managed_user.erase(t("management.users.erased_by_manager", manager: current_manager['login'])) if current_manager.present?
    destroy_session
    redirect_to management_document_verifications_path, notice: t("management.users.erased_notice")
  end

  def logout
    destroy_session
    redirect_to management_root_url, notice: t("management.sessions.signed_out_managed_user")
  end

  private

    def user_params
      params.require(:user).permit(:document_type, :document_number, :username, :email, :date_of_birth)
    end

    def residence_params
      {
        document_type: params[:user][:document_type],
        document_number: params[:user][:document_number],
        date_of_birth: params[:user][:date_of_birth],
        postal_code: '12000'
      }

    end

    def destroy_session
      session[:document_type] = nil
      session[:document_number] = nil
    end

    def verificar_residencia
      residence =  Verification::Residence.new(residence_params)
      if residence.save
        Time.now
      else
        nil
      end
    end

end
