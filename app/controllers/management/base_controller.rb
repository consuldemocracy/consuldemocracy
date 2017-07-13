class Management::BaseController < ActionController::Base
  layout 'management'

  before_action :verify_manager
  before_action :set_locale

  helper_method :managed_user

  private

    def verify_manager
      raise ActionController::RoutingError.new('Not Found') if current_manager.blank?
    end

    def current_manager
      session[:manager]
    end

    def current_user
      managed_user
    end

    def managed_user
      @managed_user ||= Verification::Management::ManagedUser.find(session[:document_type], session[:document_number])
    end

    def check_verified_user(alert_msg)
      unless managed_user.level_two_or_three_verified?
        redirect_to management_document_verifications_path, alert: alert_msg
      end
    end

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      I18n.locale = session[:locale]
    end

end
