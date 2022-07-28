class Management::BaseController < ActionController::Base
  include GlobalizeFallbacks
  layout "management"
  default_form_builder ConsulFormBuilder

  before_action :verify_manager
  around_action :switch_locale

  helper_method :managed_user
  helper_method :current_user
  helper_method :manager_logged_in

  private

    def verify_manager
      raise ActionController::RoutingError, "Not Found" if current_manager.blank?
    end

    def current_manager
      session[:manager]
    end

    def current_user
      managed_user
    end

    def managed_user
      @managed_user ||= Verification::Management::ManagedUser.find(
        session[:document_type],
        session[:document_number]
      )
    end

    def check_verified_user(alert_msg)
      return if managed_user.persisted? && managed_user.level_two_or_three_verified?

      message = managed_user.persisted? ? alert_msg : t("management.sessions.need_managed_user")
      redirect_to management_document_verifications_path, alert: message
    end

    def switch_locale(&action)
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      I18n.with_locale(session[:locale], &action)
    end

    def current_budget
      Budget.current
    end

    def clear_password
      session[:new_password] = nil
    end

    def manager_logged_in
      if current_manager
        @manager_logged_in = User.find_by_manager_login(session[:manager]["login"])
      end
    end
end
