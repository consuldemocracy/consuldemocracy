class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
skip_before_filter :verify_authenticity_token

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)
        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end

  [:twitter, :facebook, :google_oauth2, :openid].each do |provider|
    provides_callback_for provider
  end
  #[:openid].each do |provider|
  #  openid_callback(provider)
  #end
  #def self.openid_callback(provider)
    # You need to implement the method below in your model
  #  @user = User.find_for_open_id(env["omniauth.auth"], current_user)
  #  if @user.persisted?
  #    sign_in_and_redirect @user, :event => :authentication
  #    set_flash_message(:notice, :success, kind: "Participa".capitalize) if is_navigational_format?
  #  else
  #    session["devise.openid_data"] = env["omniauth.auth"]
  #    redirect_to new_user_registration_url
  #  end
  #end

  def after_sign_in_path_for(resource)
    if resource.email_provided?
      super(resource)
    else
      finish_signup_path
    end
  end

end
