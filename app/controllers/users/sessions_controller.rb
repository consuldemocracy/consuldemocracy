class Users::SessionsController < Devise::SessionsController
  prepend_before_action :authenticate_with_otp, only: [:create]
  
    
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end
  
  def destroy
    @stored_location = stored_location_for(:user)
    super
  end

  private

    def after_sign_in_path_for(resource)
      if Rails.application.multitenancy_management_mode? && !resource.administrator?
        account_path
      elsif !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      @stored_location.present? && !@stored_location.match("management") ? @stored_location : super
    end

    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
    
    def authenticate_with_otp
    user = User.find_by(email: params[:user][:email])
    return unless user&.requires_2fa?

    if user.validate_and_consume_otp!(params[:user][:otp_attempt])
      sign_in user
    else
      flash[:alert] = 'Invalid OTP'
      redirect_to new_user_session_path
    end
  end
end
