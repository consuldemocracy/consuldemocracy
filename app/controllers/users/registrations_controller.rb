class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy, :finish_signup, :do_finish_signup]

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super
    else
      render :new
    end
  end

  def delete_form
    build_resource({})
  end

  def delete
    current_user.erase(erase_params[:erase_reason])
    sign_out
    redirect_to root_url, notice: t("devise.registrations.destroyed")
  end

  def success
  end

  def finish_signup
  end

  def do_finish_signup
    if current_user.update(sign_up_params)
      current_user.skip_reconfirmation!
      sign_in(current_user, bypass: true)
      redirect_to root_url
    else
      render :finish_signup
    end
  end

  def validate
    build_resource(sign_up_params)
    resource.valid?
    render json: resource.errors
  end

  private

    def sign_up_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :captcha, :captcha_key, :terms_of_service)
    end

    def erase_params
      params.require(:user).permit(:erase_reason)
    end

    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end

end
