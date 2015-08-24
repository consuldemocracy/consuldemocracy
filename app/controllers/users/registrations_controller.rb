class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy, :finish_signup, :do_finish_signup]

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super
    else
      render :new
    end
  end

  def finish_signup
  end

  def do_finish_signup
    if current_user.update(sign_up_params)
      current_user.skip_reconfirmation!
      sign_in(current_user, bypass: true)
      redirect_to root_url, notice: I18n.t('devise.registrations.updated')
    else
      @show_errors = true
      render :finish_signup
    end
  end

  private

    def sign_up_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :captcha, :captcha_key)
    end

end
