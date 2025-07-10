module AccessDeniedHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.html { redirect_to main_app.root_path, alert: exception.message }
        format.json { render json: { error: exception.message }, status: :forbidden }
      end
    end
  end
end
