class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    sign_in_with :twitter
  end

  def facebook
    sign_in_with :facebook
  end

  def google_oauth2
    sign_in_with :google_oauth2
  end

  def after_sign_in_path_for(resource)
    if resource.email_provided?
      super(resource)
    else
      finish_signup_path
    end
  end

  private

    def sign_in_with(provider)
      auth = env["omniauth.auth"]

      identity = Identity.first_or_create_from_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)

      if @user.save
        identity.update(user: @user)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end

end
