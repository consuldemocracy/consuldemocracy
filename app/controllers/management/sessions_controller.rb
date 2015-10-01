class Management::SessionsController < ActionController::Base

  def create
    destroy_session
    if manager = Manager.valid_manager(params[:login], params[:clave_usuario])
      session["manager_id"] = manager.id
      redirect_to management_root_path
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private
    def destroy_session
      session["manager_id"] = nil
    end
end