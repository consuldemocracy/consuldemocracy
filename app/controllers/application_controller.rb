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
end
