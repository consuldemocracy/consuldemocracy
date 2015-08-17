class Organizations::RegistrationsController < Devise::RegistrationsController
  def new
    super do |user|
      user.build_organization
    end
  end

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super do |user|
        # Removes unuseful "organization is invalid" error message
        user.errors.messages.delete(:organization)
      end
    else
      render :new
    end
  end

  private

    def sign_up_params
      params.require(:user).permit(:email, :password, :phone_number, :password_confirmation, :captcha, :captcha_key, organization_attributes: [:name])
    end

end
