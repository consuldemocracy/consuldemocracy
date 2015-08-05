class RegistrationsController < Devise::RegistrationsController
  include RecaptchaHelper

  def create
    if verify_captcha?(resource)
      super
    else
      build_resource(sign_up_params)
      flash.now[:alert] = t('recaptcha.errors.verification_failed')
      render :new
    end
  end


  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

end