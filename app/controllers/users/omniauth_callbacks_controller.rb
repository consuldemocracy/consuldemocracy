class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
skip_before_filter :verify_authenticity_token

  def self.provides_callback_for(provider)
    class_eval %Q{
    if provider != :reddit
      def #{provider}
        @user = User.find_for_oauth(env['omniauth.auth'], current_user)
        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          #set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env['omniauth.auth']
          redirect_to new_user_registration_url
        end
      end
    else
      def #{provider}
        @user = User.find_for_oauth(env['omniauth.auth'], current_user)
        session["devise.#{provider}_data"] = env['omniauth.auth']
        if @user.persisted?
          #sign_in_and_redirect @user, event: :authentication
          #set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
          User.add_reddituser!(env['omniauth.auth'],current_user)
          redirect_to account_path
          #set_flash_message(:notice, :success, kind: "Usuario de Reddit Vinculado Correctamente") if is_navigational_format?
        else
          #session["devise.#{provider}_data"] = env['omniauth.auth']
          #redirect_to new_user_registration_url
        end
      end
    end
    }
  end

  [:twitter, :facebook, :google_oauth2, :openid, :reddit].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_provided?
      super(resource)
    else
      finish_signup_path
    end
  end

end
