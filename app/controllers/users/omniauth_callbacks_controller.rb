class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    sign_in_with :twitter_login, :twitter
  end

  def facebook
    sign_in_with :facebook_login, :facebook
  end

  def google_oauth2
    sign_in_with :google_login, :google_oauth2
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      super(resource)
    end
  end

  private

    def sign_in_with(feature, provider)
      raise ActionController::RoutingError.new('Not Found') unless Setting["feature.#{feature}"]

      auth = env["omniauth.auth"]

      identity = Identity.first_or_create_from_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)

      if save_user(@user)
        identity.update(user: @user)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
      else
        # If saving the user was not possible (weird errors, etc) just present the "new user" form
        session["devise.#{provider}_data"] = auth
        redirect_to new_user_registration_url
      end
    end

    def save_user(user)
      # If there are no problems with the email/username, then they were provided by oauth or they
      # correspond to an existing user. Associate the identity and sign in
      return true if @user.save

      # If either the username or email have provoked a failure, we save the user anyway (but marked for revision)
      # This mark will be detected by applicationcontroller and the user will be redirected to finish_signup
      @user.registering_with_oauth = true
      return true if @user.save

      # If we still can't save the user, the email might be invalidating devise's validatable "unique"
      # constraint. Set email to nil and try again (we'll reset later using oauth_email)
      @user.email = nil
      @user.save
    end

end
