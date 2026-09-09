class Management::BaseController < ActionController::Base
  include TenantVariants
  include GlobalizeFallbacks
  include AccessDeniedHandler

  layout "management"
  default_form_builder ConsulFormBuilder

  before_action :authenticate_user!, unless: :external_manager?
  before_action :verify_manager
  around_action :switch_locale

  helper_method :managed_user
  helper_method :manager_user
  helper_method :current_user

  private

    def verify_manager
      raise CanCan::AccessDenied if current_manager.blank?
    end

    def current_manager
      @current_manager ||= external_manager || manager_user
    end

    def current_manager_login
      if external_manager
        current_manager[:login]
      else
        if current_manager.administrator?
          "admin_user_#{current_manager.id}"
        else
          "manager_user_#{current_manager.id}"
        end
      end
    end

    def external_manager
      session[:manager]
    end

    def external_manager?
      external_manager.present?
    end

    def manager_user
      user = warden.authenticate!(scope: :user)

      user if user.administrator? || user.manager?
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
      if params[:locale] && Setting.enabled_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale].to_s
      end

      session[:locale] ||= Setting.default_locale.to_s

      I18n.with_locale(session[:locale], &action)
    end

    def clear_password
      session[:new_password] = nil
    end
end
