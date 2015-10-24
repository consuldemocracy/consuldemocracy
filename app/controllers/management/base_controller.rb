class Management::BaseController < ActionController::Base
  layout 'management'

  before_action :verify_manager
  before_action :set_locale

  helper_method :managed_user

  private

    def verify_manager
      raise ActionController::RoutingError.new('Not Found') unless current_manager.present?
    end

    def current_manager
      session[:manager]
    end

    def managed_user
      @managed_user ||= Verification::Management::ManagedUser.find(session[:document_type], session[:document_number])
    end

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      I18n.locale = session[:locale]
    end

end
