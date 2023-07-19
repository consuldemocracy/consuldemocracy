class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!,
                        only: [:edit, :update, :destroy, :finish_signup, :do_finish_signup]
  before_action :configure_permitted_parameters

  invisible_captcha only: [:create], honeypot: :address, scope: :user

  def new
    super do |user|
      user.use_redeemable_code = true if params[:use_redeemable_code].present?
    end
  end

  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

    if resource.valid?
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
    redirect_to root_path, notice: t("devise.registrations.destroyed")
  end

  def success
  end

  def finish_signup
    current_user.registering_with_oauth = false
    current_user.email = current_user.oauth_email if current_user.email.blank?
    current_user.validate
  end

  def do_finish_signup
    current_user.registering_with_oauth = false
    if current_user.update(sign_up_params)
      current_user.send_oauth_confirmation_instructions
      sign_in_and_redirect current_user, event: :authentication
    else
      render :finish_signup
    end
  end

  def check_username
    if User.find_by username: params[:username]
      render json: { available: false,
                     message: t("devise_views.users.registrations.new.username_is_not_available") }
    else
      render json: { available: true,
                     message: t("devise_views.users.registrations.new.username_is_available") }
    end
  end

  private

    def sign_up_params
      if params[:user].present? && params[:user][:redeemable_code].blank?
        params[:user].delete(:redeemable_code)
      end

      params.require(:user).permit(allowed_params)
    end

    def allowed_params
      [
        :username, :email, :password,
        :password_confirmation, :terms_of_service, :locale,
        :redeemable_code
      ]
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email])
    end

    def erase_params
      params.require(:user).permit(:erase_reason)
    end

    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end
end
