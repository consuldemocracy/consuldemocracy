class ApplicationController < ActionController::Base
  include TenantVariants
  include GlobalizeFallbacks
  include HasFilters
  include HasOrders
  include AccessDeniedHandler

  default_form_builder ConsulFormBuilder

  before_action :authenticate_http_basic, if: :http_basic_auth_site?

  before_action :ensure_signup_complete
  around_action :switch_locale
  before_action :set_return_url
  
  before_action :enforce_two_factor_for_admins
  
  check_authorization unless: :devise_controller?
  self.responder = ApplicationResponder

  layout :set_layout
  respond_to :html
  helper_method :current_budget

  private

    def authenticate_http_basic
      authenticate_or_request_with_http_basic do |username, password|
        username == Tenant.current_secrets.http_basic_username &&
          password == Tenant.current_secrets.http_basic_password
      end
    end

    def http_basic_auth_site?
      Tenant.current_secrets.http_basic_auth
    end

    def verify_lock
      if current_user.locked?
        redirect_to account_path, alert: t("verification.alert.lock")
      end
    end

    def switch_locale(&action)
      locale = current_locale

      if current_user && current_user.locale != locale.to_s
        current_user.update(locale: locale)
      end

      session[:locale] = locale.to_s
      I18n.with_locale(locale, &action)
    end

    def current_locale
      if Setting.enabled_locales.include?(params[:locale]&.to_sym)
        params[:locale]
      elsif Setting.enabled_locales.include?(session[:locale]&.to_sym)
        session[:locale]
      else
        Setting.default_locale
      end
    end

    def set_layout
      if devise_controller?
        "devise"
      else
        "application"
      end
    end

    def set_comment_flags(comments)
      @comment_flags = current_user ? current_user.comment_flags(comments) : {}
    end

    def ensure_signup_complete
      if user_signed_in? && !devise_controller? && current_user.registering_with_oauth
        redirect_to finish_signup_path
      end
    end

    def verify_resident!
      unless current_user.residence_verified?
        redirect_to new_residence_path, alert: t("verification.residence.alert.unconfirmed_residency")
      end
    end

    def verify_verified!
      if current_user.level_three_verified?
        redirect_to(account_path, notice: t("verification.redirect_notices.already_verified"))
      end
    end

    def set_return_url
      if request.get? && !devise_controller? && is_navigational_format?
        store_location_for(:user, request.fullpath)
      end
    end

    def current_budget
      Budget.current
    end

    def redirect_with_query_params_to(options, response_status = {})
      path_options = { controller: params[:controller] }.merge(options).merge(only_path: true)
      path = url_for(request.query_parameters.merge(path_options))

      redirect_to path, response_status
    end
    
      def enforce_two_factor_for_admins
    # 1. First, do nothing if no user is signed in.
    return unless user_signed_in?

    # 2. Next, do nothing if the user is not an admin.
    return unless current_user.administrator?

    # 3. If the admin has already enabled 2FA, we're done. Do nothing.
    return if current_user.otp_two_factor_enabled?

    # 4. CRITICAL: To prevent an infinite redirect loop, we must NOT redirect
    #    if the user is already on a page needed for the setup process.
    return if on_an_allowed_page?

    # 5. If all checks fail, the user is an admin who needs to set up 2FA.
    #    Redirect them to the setup page with an alert.
    redirect_to account_two_factor_authentication_path,
                alert: 'As an administrator, you must enable two-factor authentication to continue.'
  end
  
  # Helper method to define the pages an admin can visit during setup.
  def on_an_allowed_page?
    # Allow access to any Devise-related controller (sessions, registrations, etc.)
    # so they can log out if needed.
    return true if devise_controller?

    # Allow access to the two_factor_authentication controller itself.
    allowed_controllers = ["two_factor_authentication", "two_factor_authentications"]
    return true if allowed_controllers.include?(controller_name)
  end
end
