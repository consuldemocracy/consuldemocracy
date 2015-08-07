require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :set_locale
  layout :set_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

  def verify_captcha?(resource)
    return true unless recaptcha_keys?
    verify_recaptcha(model: resource)
  end

end
