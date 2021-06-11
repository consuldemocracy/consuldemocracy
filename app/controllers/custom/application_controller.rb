require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController < ActionController::Base
  before_action :check_iframe
  after_action :set_iframe
  def set_default_budget_filter
    if @budget&.balloting? || @budget&.publishing_prices? || @budget&.reviewing_ballots? || @budget&.finished?
      params[:filter] ||= "selected"
    end
  end
  private
    # Sobrecargamos el método del ApplicationController principal, para
    # introducir como location actual no el path, sino el request.fullpath
    # a fin de garantizar que no se pierden los parametros de la URL
    # de vuelta
    # Detectado al acceder a los presupuestos de un año, al salir el botón
    # firmar llevaba de vuelta a la página global de los presupuestos y no
    # al del presupuesto activo
    def set_return_url
      if !devise_controller? && controller_name != "welcome" && is_navigational_format?
        store_location_for(:user, request.fullpath)
      end
    end

    def check_iframe
      if params[:iframed]
        session[:iframed] = true
      end
    end
    def set_iframe
      if(Rails.application.config.respond_to?(:participacion_push_target_origin))
        response.set_header("Content-Security-Policy", "frame-ancestors 'self' "+Rails.application.config.participacion_push_target_origin+";")
      end

    end

end
