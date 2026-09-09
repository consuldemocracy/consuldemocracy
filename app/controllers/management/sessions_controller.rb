class Management::SessionsController < ActionController::Base
  include TenantVariants
  include GlobalizeFallbacks
  include AccessDeniedHandler

  default_form_builder ConsulFormBuilder

  def create
    destroy_session
    if current_user&.administrator? || current_user&.manager? || authenticated_manager?
      redirect_to management_root_path
    else
      raise CanCan::AccessDenied
    end
  end

  private

    def destroy_session
      session[:manager] = nil
      session[:document_type] = nil
      session[:document_number] = nil
    end

    def authenticated_manager?
      manager = ManagerAuthenticator.new(params).auth
      session[:manager] = manager if manager.present?
    end
end
