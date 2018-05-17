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

      identity = Identity.find_by_provider_and_uid(auth['provider'], auth['uid'])
      if identity.present?
        sign_in_and_redirect(identity.user, event: :authentication)
        set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
      elsif current_user
        # Add an identity omniauth
        current_user.fill_from_omniauth(auth)
        if current_user.save
          flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: provider.to_s.capitalize)
          redirect_to account_path
        else
          flash[:warning] = I18n.t("devise.omniauth_callbacks.failure", kind: provider.to_s.capitalize, reason: "il y a eu un problème technique.")
          render account_path
        end
      else
        # Registration - (method `Account.new_with_session` is called)
        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: provider.to_s.capitalize)
        session["omniauth"] = auth
        redirect_to new_user_registration_path
      end
    end

end
