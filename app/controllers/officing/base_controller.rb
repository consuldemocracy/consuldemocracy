class Officing::BaseController < ActionController::Base
  layout 'admin'

  #before_action :verify_officer
  before_action :set_locale

  private

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      I18n.locale = session[:locale]
    end
end