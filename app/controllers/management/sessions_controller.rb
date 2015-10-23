require "manager_authenticator"

class Management::SessionsController < ActionController::Base

  def create
    destroy_session
    if manager = ManagerAuthenticator.new(params).auth
      session[:manager] = manager
      redirect_to management_root_path
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def destroy
    destroy_session
    redirect_to root_path, notice: t("management.sessions.signed_out")
  end

  private

    def destroy_session
      session[:manager] = nil
      session[:document_type] =   nil
      session[:document_number] = nil
    end

end