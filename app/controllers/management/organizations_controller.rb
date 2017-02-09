class Management::OrganizationsController < Management::BaseController

  def new
    @user = User.new
    @user.build_organization
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
    @user.registering_with_oauth = true
    @user.confirmed_at = Time.zone.now
    @user.residence_verified_at = Time.zone.now
    @user.level_two_verified_at = Time.zone.now
    @user.verified_at = Time.zone.now
    @user.terms_of_service = '1'
    if @user.save
      @user.send_reset_password_instructions
      redirect_to management_root_url
    else
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
      params.require(:user).permit(:email, :password, :phone_number, :password_confirmation, :terms_of_service, organization_attributes: [:name, :responsible_name])
    end

    def xxxuser_params
      params.require(:user).permit(:document_type, :document_number, :username, :email, :date_of_birth)
    end

    def residence_params
      params_for_residence = params[:user].except(:username, :email)
      params_for_residence.merge!(user: @user)
      { postal_code: '12000', terms_of_service: '1' }.merge!(params_for_residence)
    end

    def destroy_session
      session[:document_type] = nil
      session[:document_number] = nil
    end

    def verificar_residencia
      verificacion = Verification::Residence.new(residence_params)
      # verificacion = PadronCastellonApi.new.call(params[:user][:document_type], params[:user][:document_number])
      if verificacion.valid?
         return Time.zone.now
       else
         return nil
       end
    end

end
