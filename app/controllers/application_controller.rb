require "application_responder"

class ApplicationController < ActionController::Base
  check_authorization unless: :devise_controller?
  include SimpleCaptcha::ControllerHelpers
  self.responder = ApplicationResponder
  respond_to :html

  before_action :set_locale
  layout :set_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :ensure_signup_complete

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, alert: exception.message
  end

  private

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      I18n.locale = session[:locale]
    end

    def set_layout
      if devise_controller?
        "devise"
      else
        "application"
      end
    end

    def set_debate_votes(debates)
      @voted_values = current_user ? current_user.debate_votes(debates) : {}
    end

    def ensure_signup_complete
      # Ensure we don't go into an infinite loop
      return if action_name.in? %w(finish_signup do_finish_signup)

      if user_signed_in? && !current_user.email_provided?
        redirect_to finish_signup_path
      end
    end

    def verify_resident!
      unless current_user.residence_verified?
        redirect_to new_residence_path, alert: t('verification.residence.alert.unconfirmed_residency')
      end
    end
end
