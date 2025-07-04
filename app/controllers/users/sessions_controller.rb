class Users::SessionsController < Devise::SessionsController
#  prepend_before_action :authenticate_with_otp_two_factor, only: [:create]
  prepend_before_action :authenticate_with_otp_two_factor,
                        if: -> { action_name == 'create' && otp_two_factor_enabled? }  
    
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
    
  def authenticate_with_otp_two_factor
  Rails.logger.info "[2FA LOGIC] ==> Starting authentication process."

  # Find the user based on the login parameters
  user = self.resource = find_user

  # Log whether a user was found
  if user.present?
    Rails.logger.info "[2FA LOGIC]     User found: ID #{user.id}, Email: #{user.email}"
  else
    Rails.logger.info "[2FA LOGIC]     User not found with provided login details. Aborting."
    # The standard Devise flow will handle the 'invalid login' message from here.
    return
  end

  # This is the second step of the login, where the user has submitted their OTP
  if user_params[:otp_attempt].present? && session[:otp_user_id]
    Rails.logger.info "[2FA LOGIC]     Detected OTP attempt. Session OTP User ID: #{session[:otp_user_id]}."
    Rails.logger.info "[2FA LOGIC]     Calling 'authenticate_user_with_otp_two_factor'..."
    authenticate_user_with_otp_two_factor(user)

  # This is the first step, where the user has just submitted their password
  elsif user.valid_password?(user_params[:password])
    Rails.logger.info "[2FA LOGIC]     Password for User ID #{user.id} is valid."
    Rails.logger.info "[2FA LOGIC]     Calling 'prompt_for_otp_two_factor'..."
    prompt_for_otp_two_factor(user)

  # This else block is important for debugging
  else
    Rails.logger.info "[2FA LOGIC]     Password was invalid, or another condition was not met."
    # Let Devise's normal flow continue, which will result in an "Invalid email or password" error.
  end

  Rails.logger.info "[2FA LOGIC] ==> Finished authentication process."
end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
        user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end

  def prompt_for_otp_two_factor(user)
    @user = user

    session[:otp_user_id] = user.id
    render 'devise/sessions/two_factor'
  end

  def authenticate_user_with_otp_two_factor(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      session.delete(:otp_user_id)

      remember_me(user) if user_params[:remember_me] == '1'
      user.save!
      sign_in(user, event: :authentication)
      redirect_to root_path, notice: 'Signed in successfully'
    else
      flash.now[:alert] = 'Invalid two-factor code.'
      prompt_for_otp_two_factor(user)
    end
  end

  def user_params
    params.require(:user).permit(:login, :email, :password, :remember_me, :otp_attempt)
  end

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
 #   elsif user_params[:email]
 #     User.find_by(email: user_params[:email])
     elsif params[:user]
    # This part is for the first (password) step
    login = user_params[:login].downcase
    User.find_by("lower(email) = :login OR username = :login", { login: login })
    end
  end

  def otp_two_factor_enabled?
    find_user&.otp_required_for_login
  end

  end
