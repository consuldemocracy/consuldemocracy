class Organizations::RegistrationsController < Devise::RegistrationsController
  include RecaptchaHelper

  def new
    super do |user|
      user.build_organization
    end
  end

  def create
    if verify_captcha?(resource)
      super do |user|
        # Removes unuseful "organization is invalid" error message
        user.errors.messages.delete(:organization)
      end
    else
      build_resource(sign_up_params)
      flash.now[:alert] = t('recaptcha.errors.verification_failed')
      respond_with resource
    end
  end

  private

    def sign_up_params
      params.require(:user).permit(:email, :password, :phone_number, :password_confirmation, organization_attributes: [:name])
    end

end
