require "application_responder"

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
  include HasFilters

  before_action :authenticate_http_basic, if: :http_basic_auth_site?
  before_action :authenticate_user!, unless: :devise_controller?, if: :beta_site?
  before_action :authenticate_beta_tester!, unless: :devise_controller?, if: :beta_site?

  before_action :ensure_signup_complete
  before_action :set_locale

  check_authorization unless: :devise_controller?
  self.responder = ApplicationResponder

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, alert: exception.message
  end

  layout :set_layout
  respond_to :html

  private

    def authenticate_http_basic
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.application.secrets.http_basic_username && password == Rails.application.secrets.http_basic_password
      end
    end

    def authenticate_beta_tester!
      unless signed_in? && beta_testers.include?(current_user.email)
        sign_out(current_user)
        redirect_to new_user_session_path, alert: t('application.alert.only_beta_testers')
      end
    end

    def beta_testers
      File.readlines('config/beta-testers.txt').map {|email| email.strip }
    end

    def beta_site?
      Rails.application.secrets.beta_site
    end

    def http_basic_auth_site?
      Rails.application.secrets.http_basic_auth
    end

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
      @debate_votes = current_user ? current_user.debate_votes(debates) : {}
    end

    def set_comment_flags(comments)
      @comment_flags = current_user ? current_user.comment_flags(comments) : {}
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
