require 'viisp/auth'

class Users::SessionsController < Devise::SessionsController
  # def create
  #   #
    # VIISP::Auth.configure do |c|
    #   c.pid = 'VSID000000000113'
    #   c.private_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/testKey.pem'))
    #   c.postback_url = 'http://212.24.109.28:3000/'
    #
    #   # optional
    #   c.providers = %w[auth.lt.identity.card auth.lt.bank]
    #   c.attributes = %w[lt-personal-code lt-company-code]
    #   c.user_information = %w[firstName lastName companyName email]
    #
    #   # enable test mode
    #   # (in test mode there is no need to set pid and private_key)
    #   c.test = true#Rails.env.test? # Adjust this condition based on your environment
    # end

    # Try to find the user by login (username or email)
    #
    # self.resource = User.find_for_database_authentication(login: params[:user][:login])
    #
    # # If user doesn't exist, create a new one
    # if resource.nil?
    #   resource = User.new(
    #     username: params[:user][:login],
    #     email: params[:user][:login],
    #     password: params[:user][:password],
    #     terms_of_service: "1",
    #     confirmed_at: Time.current,
    #     verified_at: Time.current
    #   )
    #
    #   # Customize the code to set additional attributes if needed
    #   # resource.email = params[:user][:email]
    #
    #   # Save the new user
    #   if resource.save
    #     flash[:notice] = t('devise.registrations.signed_up')
    #   else
    #     flash[:alert] = resource.errors.full_messages.join(', ')
    #     redirect_to new_user_session_path and return
    #   end
    # end
    #
    # # Authenticate the user
    # if resource && resource.valid_password?(params[:user][:password])
    #   sign_in(resource_name, resource)
    #   yield resource if block_given?
    #   respond_with resource, location: after_sign_in_path_for(resource)
    # else
    #   flash[:alert] = t('devise.failure.invalid', authentication_keys: 'login')
    #   redirect_to new_user_session_path
    # end

    # ticket = VIISP::Auth.ticket
    # puts ticket

    # redirect_to VIISP::Auth.portal_endpoint
  # end

  def destroy
    @stored_location = stored_location_for(:user)
    super
  end

  private

    def after_sign_in_path_for(resource)

      if !verifying_via_email? && resource.show_welcome_screen?
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
end
