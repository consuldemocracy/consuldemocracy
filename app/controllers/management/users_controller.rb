class Management::UsersController < Management::BaseController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.email.blank?
      user_without_email
    else
      user_with_email
    end

    @user.terms_of_service = '1'
    verificado = verificar_residencia
    @user.residence_verified_at = verificado
    @user.verified_at = verificado

    if verificado
      flash[:notice] = 'Verificación correcta en el Padrón'
      if @user.save
        render :show
      else
        flash[:alert] = 'Usuario incorrecto'
        render :new
      end
    else
      flash[:alert] = 'Verificación incorrecta en el Padrón'
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
      params_for_residence = params[:user].except(:username, :email)
      { postal_code: '12000', terms_of_service: '1' }.merge!(params_for_residence)
    end

    def destroy_session
      session[:document_type] = nil
      session[:document_number] = nil
    end

    def verificar_residencia
      verificacion = Verification::Residence.new(residence_params)
      if verificacion.save
        return Time.zone.now
      else
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        puts verificacion.errors.inspect
        nil
      end
    end

end
