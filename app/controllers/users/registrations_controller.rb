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
    # The only difference between this version of delete and the original are the following two lines
    # (we build the resource differently and we also call erase instead of destroy)
    resource = current_user
    current_user.erase(erase_params[:erase_reason])

    yield resource if block_given?
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_flashing_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
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
