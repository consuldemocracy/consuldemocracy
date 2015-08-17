class RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super
    else
      render :new
    end
  end


  private

    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :use_nickname, :nickname, :captcha, :captcha_key)
    end

end
