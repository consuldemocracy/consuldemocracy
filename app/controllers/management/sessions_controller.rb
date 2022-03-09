require "manager_authenticator"

class Management::SessionsController < ActionController::Base
  include GlobalizeFallbacks
  include AccessDeniedHandler
  default_form_builder ConsulFormBuilder

  def create
    destroy_session
    if admin? || manager? || authenticated_manager?
      redirect_to management_root_path
    else
      raise CanCan::AccessDenied
    end
  end

  def destroy
    destroy_session
    redirect_to root_path, notice: t("management.sessions.signed_out")
  end

  private

    def destroy_session
      session[:manager] = nil
      session[:document_type] = nil
      session[:document_number] = nil
    end

    def admin?
      if current_user&.administrator?
        session[:manager] = { login: "admin_user_#{current_user.id}" }
      end
    end

    def manager?
      if current_user&.manager?
        session[:manager] = { login: "manager_user_#{current_user.id}" }
      end
    end

    def authenticated_manager?
      manager = ManagerAuthenticator.new(params).auth
      session[:manager] = manager if manager.present?
    end
end
