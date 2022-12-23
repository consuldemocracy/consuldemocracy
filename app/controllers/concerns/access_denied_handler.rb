module AccessDeniedHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
        format.html do
          if Rails.application.multitenancy_management_mode?
            redirect_to main_app.account_path, alert: exception.message
          else
            redirect_to main_app.root_path, alert: exception.message
          end
        end
        format.json { render json: { error: exception.message }, status: :forbidden }
      end
    end
  end
end
