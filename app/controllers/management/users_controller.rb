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

    # @user.terms_of_service = '1'

    # # @user.save

    # verificado = verificar_residencia
    # if verificado && @user.save
    #   @user.residence_verified_at = verificado
    #   @user.level_two_verified_at = verificado
    #   @user.verified_at = verificado
    #   @user.send_reset_password_instructions
    #   flash[:notice] = 'Verificación correcta en el Padrón'
    @user.terms_of_service = "1"
    @user.residence_verified_at = Time.current
    @user.verified_at = Time.current

    if @user.save
      render :show
    else
      flash[:alert] = 'Verificación incorrecta en el Padrón'
      render :new
    end
  end

  def erase
    managed_user.erase(t("management.users.erased_by_manager", manager: current_manager["login"])) if current_manager.present?
    destroy_session
    redirect_to management_document_verifications_path, notice: t("management.users.erased_notice")
  end

  def logout
    destroy_session
    redirect_to management_root_path, notice: t("management.sessions.signed_out_managed_user")
  end

  private

    def user_params
      params.require(:user).permit(allowed_params)
    end

    def allowed_params
      [:document_type, :document_number, :username, :email, :date_of_birth]
    end

    def residence_params
      params_for_residence = params[:user].except(:username, :email)
      params_for_residence.merge!(user: @user)
      { postal_code: '12000', terms_of_service: '1' }.merge!(params_for_residence)
    end

    def destroy_session
      session[:document_type] = nil
      session[:document_number] = nil
      clear_password
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

    def user_without_email
      new_password = "aAbcdeEfghiJkmnpqrstuUvwxyz23456789$!".chars.sample(10).join
      @user.password = new_password
      @user.password_confirmation = new_password

      @user.email = nil
      @user.confirmed_at = Time.current

      @user.newsletter = false
      @user.email_on_proposal_notification = false
      @user.email_digest = false
      @user.email_on_direct_message = false
      @user.email_on_comment = false
      @user.email_on_comment_reply = false
    end

    def user_with_email
      @user.skip_password_validation = true
    end
end
